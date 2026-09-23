import json
import subprocess
import tomllib
import yaml
import os

# Derivations that show up in `config.home.packages` but are Home Manager's
# own internal plumbing (fontconfig cache dirs, generated manpage/session-vars
# scripts, ...), not something the user actually asked to install. Filtered
# out of the generated package docs.
NOISE_PACKAGES = {
    "home-configuration-reference-manpage",
    "hm-session-vars.sh",
}

# system -> which doc column it maps to.
SYSTEMS = {
    "x86_64-linux": "in_linux",
    "aarch64-darwin": "in_mac",
}


def _is_noise(name):
    return name in NOISE_PACKAGES or name.startswith("dummy-")


def _mise_registry_description(tool_name):
    """Look up a tool's description from `mise registry <name> --json`. Handles
    the `backend:package` shorthand (e.g. "pipx:jrnl") by looking up the
    package part. Returns None if the tool isn't in the registry or has no
    description there (e.g. "golang" is a core-plugin alias for "go" that
    isn't listed under that name; "pipx" itself has an empty description)."""
    lookup_name = tool_name.split(':', 1)[1] if ':' in tool_name else tool_name
    result = subprocess.run(
        ['mise', 'registry', lookup_name, '--json'],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    try:
        return json.loads(result.stdout).get('description') or None
    except json.JSONDecodeError:
        return None


def extract_mise_tools(mise_global_toml, output_file):
    """Read config/mise/global.toml [tools], preferring the description from
    `mise registry` (source of truth) and falling back to [_.descriptions]
    for tools the registry doesn't know about or has no description for."""
    with open(mise_global_toml, 'rb') as f:
        config = tomllib.load(f)

    tools = config.get('tools', {})
    descriptions = config.get('_', {}).get('descriptions', {})

    mise_packages = []
    for name, version_spec in tools.items():
        # version_spec can be a string or a dict with a "version" key
        description = _mise_registry_description(name) or descriptions.get(name, '')
        mise_packages.append({
            'name': name,
            'description': description,
            'in_linux': 'yes',
            'in_mac': 'yes',
        })

    with open(output_file, 'w') as f:
        yaml.dump({'mise_packages': mise_packages}, f, default_flow_style=False)


def extract_nix_packages(flake_dir, output_file):
    """Evaluate `config.home.packages` for each target system via `nix eval`
    (pure evaluation, no build required) and merge the results into a single
    package list with per-OS presence flags. Requires `nix` with flakes/
    nix-command enabled on PATH (same assumption already made by the
    `nixfmt`/`deadnix` pre-commit hooks in this repo)."""
    presence = {}

    for system, os_column in SYSTEMS.items():
        result = subprocess.run(
            [
                'nix', 'eval', '--impure', '--json',
                f'.#homeConfigurations.{system}.config.home.packages',
                '--apply',
                'pkgs: map (p: { name = p.pname or p.name; '
                'description = p.meta.description or ""; }) pkgs',
            ],
            cwd=flake_dir,
            check=True,
            capture_output=True,
            text=True,
        )
        for pkg in json.loads(result.stdout):
            name = pkg['name']
            if _is_noise(name):
                continue
            entry = presence.setdefault(name, {
                'name': name,
                'description': pkg['description'],
                'in_linux': 'no',
                'in_mac': 'no',
            })
            if not entry['description'] and pkg['description']:
                entry['description'] = pkg['description']
            entry[os_column] = 'yes'

    nix_packages = sorted(presence.values(), key=lambda p: p['name'])

    with open(output_file, 'w') as f:
        yaml.dump({'nix_packages': nix_packages}, f, default_flow_style=False)


def main():
    base = os.path.dirname(os.path.dirname(__file__))

    extract_nix_packages(base, 'docs/nix_packages.yml')

    tool_versions_file = os.path.join(base, 'config', 'mise', 'global.toml')
    extract_mise_tools(tool_versions_file, 'docs/mise_packages.yml')

    print("✅ Packages extracted successfully!")
    print("Generated: docs/nix_packages.yml, docs/mise_packages.yml")

if __name__ == '__main__':
    main()
