import yaml
import re
import os

def extract_packages_from_yaml(yaml_files, output_files):
    # Initialize data structures for package categorization
    package_presence = {}

    for yaml_file in yaml_files:
        # Determine the source file
        source_file = 'full' if 'full' in yaml_file else 'light'

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

            # Stop processing if a new section is detected with the format '- '
            if re.match(r'^- ', line) and current_section:
                if not (line.startswith('- apt:') or line.startswith('- brew:')):
                    current_section = None

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
                parts = re.split(r'\s*######\s*', line, 1)
                package_name = parts[0].strip()
                description = parts[1].strip() if len(parts) > 1 else ''

                # Update package presence
                if package_name not in package_presence:
                    package_presence[package_name] = {
                        'in_full': 'no',
                        'in_light': 'no',
                        'description': description,
                        'section': current_section
                    }
                package_presence[package_name][f'in_{source_file}'] = 'yes'

    # Separate packages into apt and brew lists
    apt_packages = []
    brew_packages = []

    for package_name, presence in package_presence.items():
        package = {
            'name': package_name,
            'description': presence['description'],
            'in_full': presence['in_full'],
            'in_light': presence['in_light']
        }
        # Assign to apt or brew list based on section
        if presence['section'] == 'apt':
            apt_packages.append(package)
        elif presence['section'] == 'brew':
            brew_packages.append(package)

    # Write to output YAML files
    with open(output_files['apt'], 'w') as file:
        yaml.dump({'apt_packages': apt_packages}, file, default_flow_style=False)

    with open(output_files['brew'], 'w') as file:
        yaml.dump({'brew_packages': brew_packages}, file, default_flow_style=False)

if __name__ == '__main__':
    # Define the input YAML files and output files
    input_files = [
        os.path.join(os.path.dirname(os.path.dirname(__file__)), 'full.conf.yaml'),
        os.path.join(os.path.dirname(os.path.dirname(__file__)), 'light.conf.yaml')
    ]
    output_files = {'apt': 'docs/apt_packages.yml', 'brew': 'docs/brew_packages.yml'}

    extract_packages_from_yaml(input_files, output_files)
