import yaml
import re
import os

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
            elif re.match(r'^\s*-\s*asdf:', line):
                current_section = 'asdf'
                continue
            elif re.match(r'^\s*-\s*shell:', line):
                current_section = 'shell'
                continue

            # Stop processing if a new section is detected with the format '- '
            if re.match(r'^- ', line) and current_section:
                if not (line.startswith('- apt:') or line.startswith('- brew:') or line.startswith('- asdf:') or line.startswith('- shell:')):
                    current_section = None
                    continue

            # Process lines based on the current section
            if current_section in ['apt', 'brew', 'asdf']:
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

                # Handle asdf plugin syntax: "plugin: name"
                if current_section == 'asdf' and 'plugin:' in package_part:
                    package_name = package_part.split('plugin:')[1].strip()
                else:
                    package_name = package_part

                # Update package presence for apt, brew, asdf sections
                if package_name not in package_presence:
                    package_presence[package_name] = {
                        'in_linux': 'no',
                        'in_mac': 'no',
                        'description': description,
                        'section': current_section
                    }
                for col in os_columns:
                    package_presence[package_name][col] = 'yes'

            elif current_section == 'shell':
                # Look for asdf plugin add commands (can be indented in command blocks)
                if 'asdf plugin add' in line and '######' in line:
                    # Format: asdf plugin add <name> || true  ###### Description
                    parts = re.split(r'\s*######\s*', line, maxsplit=1)
                    command_part = parts[0].strip()
                    description = parts[1].strip() if len(parts) > 1 else ''

                    # Extract plugin name from command
                    match = re.search(r'asdf plugin add\s+(\S+)', command_part)
                    if match:
                        package_name = match.group(1)

                        if package_name not in package_presence:
                            package_presence[package_name] = {
                                'in_linux': 'no',
                                'in_mac': 'no',
                                'description': description,
                                'section': 'asdf'  # Map shell section to asdf for categorization
                            }
                        for col in os_columns:
                            package_presence[package_name][col] = 'yes'

    # Separate packages into apt, brew and asdf lists
    apt_packages = []
    brew_packages = []
    asdf_packages = []

    for package_name, presence in package_presence.items():
        package = {
            'name': package_name,
            'description': presence['description'],
            'in_linux': presence['in_linux'],
            'in_mac': presence['in_mac'],
        }
        # Assign to apt, brew or asdf list based on section
        if presence['section'] == 'apt':
            apt_packages.append(package)
        elif presence['section'] == 'brew':
            brew_packages.append(package)
        elif presence['section'] == 'asdf':
            asdf_packages.append(package)

    # Write to output YAML files
    with open(output_files['apt'], 'w') as file:
        yaml.dump({'apt_packages': apt_packages}, file, default_flow_style=False)

    with open(output_files['brew'], 'w') as file:
        yaml.dump({'brew_packages': brew_packages}, file, default_flow_style=False)

    with open(output_files['asdf'], 'w') as file:
        yaml.dump({'asdf_packages': asdf_packages}, file, default_flow_style=False)

def main():
    # Define the input YAML files and output files
    base = os.path.dirname(os.path.dirname(__file__))
    input_files = [
        os.path.join(base, 'common.conf.yaml'),
        os.path.join(base, 'linux.conf.yaml'),
        os.path.join(base, 'mac.conf.yaml'),
    ]
    output_files = {'apt': 'docs/apt_packages.yml', 'brew': 'docs/brew_packages.yml', 'asdf': 'docs/asdf_packages.yml'}

    extract_packages_from_yaml(input_files, output_files)
    print("✅ Packages extracted successfully!")
    print(f"Generated: {', '.join(output_files.values())}")

if __name__ == '__main__':
    main()
