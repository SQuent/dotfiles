import tomllib
import yaml
import re
import os


def extract_mise_tools(mise_global_toml, output_file):
    """Read config/mise/global.toml [tools] + [_.descriptions] and output docs/mise_packages.yml."""
    with open(mise_global_toml, 'rb') as f:
        config = tomllib.load(f)

    tools = config.get('tools', {})
    descriptions = config.get('_', {}).get('descriptions', {})

    mise_packages = []
    for name, version_spec in tools.items():
        # version_spec can be a string or a dict with a "version" key
        mise_packages.append({
            'name': name,
            'description': descriptions.get(name, ''),
            'in_linux': 'yes',
            'in_mac': 'yes',
        })

    with open(output_file, 'w') as f:
        yaml.dump({'mise_packages': mise_packages}, f, default_flow_style=False)


def extract_packages_from_yaml(yaml_files, output_files):
    # Initialize data structures for package categorization
    package_presence = {}

    # Mapping: filename keyword -> which OS columns to mark as 'yes'
    # common -> both linux and mac
    # linux  -> linux only
    # mac    -> mac only
    SOURCE_MAP = {
        'common': ['in_linux', 'in_mac'],
        'linux':  ['in_linux'],
        'mac':    ['in_mac'],
    }

    for yaml_file in yaml_files:
        # Determine which OS columns to populate based on filename
        basename = os.path.basename(yaml_file)
        source_key = None
        for key in SOURCE_MAP:
            if key in basename:
                source_key = key
                break
        if source_key is None:
            continue  # Skip unknown files

        os_columns = SOURCE_MAP[source_key]

        # Read the YAML file
        with open(yaml_file, 'r') as file:
            lines = file.readlines()

        current_section = None

        for line in lines:
            line = line.rstrip()  # Remove trailing newlines and spaces

            # Detect the start of a new section
            if re.match(r'^\s*-\s*apt:', line):
                current_section = 'apt'
                continue
            elif re.match(r'^\s*-\s*brew:', line):
                current_section = 'brew'
                continue

            elif re.match(r'^\s*-\s*shell:', line):
                current_section = 'shell'
                continue

            # Stop processing if a new section is detected with the format '- '
            if re.match(r'^- ', line) and current_section:
                if not (line.startswith('- apt:') or line.startswith('- brew:') or line.startswith('- shell:')):
                    current_section = None
                    continue

            # Process lines based on the current section
            if current_section in ['apt', 'brew']:
                if re.match(r'^\s*#\s*-\s+', line):
                    # Commented package - Skip it
                    continue
                elif re.match(r'^\s*-\s+', line):
                    # Active package
                    line = line.lstrip('- ').strip()
                else:
                    continue  # Skip non-package lines

                # Extract package name and description
                parts = re.split(r'\s*######\s*', line, maxsplit=1)
                package_part = parts[0].strip()
                description = parts[1].strip() if len(parts) > 1 else ''

                package_name = package_part
                if package_name not in package_presence:
                    package_presence[package_name] = {
                        'in_linux': 'no',
                        'in_mac': 'no',
                        'description': description,
                        'section': current_section,
                    }
                for col in os_columns:
                    package_presence[package_name][col] = 'yes'

    apt_packages = []
    brew_packages = []

    for package_name, presence in package_presence.items():
        package = {
            'name': package_name,
            'description': presence['description'],
            'in_linux': presence['in_linux'],
            'in_mac': presence['in_mac'],
        }
        if presence['section'] == 'apt':
            apt_packages.append(package)
        elif presence['section'] == 'brew':
            brew_packages.append(package)

    # Write to output YAML files
    with open(output_files['apt'], 'w') as file:
        yaml.dump({'apt_packages': apt_packages}, file, default_flow_style=False)

    with open(output_files['brew'], 'w') as file:
        yaml.dump({'brew_packages': brew_packages}, file, default_flow_style=False)

def main():
    base = os.path.dirname(os.path.dirname(__file__))
    input_files = [
        os.path.join(base, 'common.conf.yaml'),
        os.path.join(base, 'linux.conf.yaml'),
        os.path.join(base, 'mac.conf.yaml'),
    ]
    output_files = {'apt': 'docs/apt_packages.yml', 'brew': 'docs/brew_packages.yml'}
    extract_packages_from_yaml(input_files, output_files)

    tool_versions_file = os.path.join(base, 'config', 'mise', 'global.toml')
    extract_mise_tools(tool_versions_file, 'docs/mise_packages.yml')

    print("✅ Packages extracted successfully!")
    print(f"Generated: {', '.join(list(output_files.values()) + ['docs/mise_packages.yml'])}")

if __name__ == '__main__':
    main()
