import os
import shutil
from concurrent.futures import ThreadPoolExecutor
from subprocess import Popen, PIPE
from export_config import get_openscad_location, get_stl_output_directory, get_manifold_support, get_project_root
from numbers import Number

part_map = {
    'cupiter': {
        'frame': {
            'folder_test': {
                'arm_upper': {
                    'part': 'arm_upper',
                    'quantity': 2,
                    'size': 20
                },
                'arm_lower': {
                    'part': 'arm_lower',
                    'size': 20
                }
            },
            'test_test': {
                'part': 'leg_lower',
                'quantity': 2,
                'size': 20
            }
        }
    }
}

def is_part_definition(dictionary):
    return all(not isinstance(value, dict) for value in dictionary.values())

def flatten_to_folders_and_parts(parts, current_path = ''):
    folders_and_parts = {}
    for key, value in parts.items():
        if is_part_definition(value):
            if folders_and_parts.get(current_path):
                folders_and_parts[current_path].update({ key: value })
            else:
                folders_and_parts[current_path] = { key: value }
        else:
            folders_and_parts.update(flatten_to_folders_and_parts(value, current_path + '/' + key))
    return folders_and_parts

def generate_part(output_directory, folder, part):
    part_file_name = part[0] + '.stl'
    print(part_file_name)
    os.makedirs(output_directory, exist_ok=True)

    args = [
        get_openscad_location(),
        '-o' + output_directory + part_file_name,
        get_project_root() + '/src/scad/print map.scad'
    ]

    for arg, value in part[1].items():
        if isinstance(value, Number) and arg != 'quantity':
            args.append('-D' + arg + '=' + str(value))
        elif isinstance(value, str):
            args.append('-D' + arg + '="' + value + '"')

    if get_manifold_support():
        args.append('--enable=manifold')

    process = Popen(args, stdout=PIPE, stderr=PIPE)
    _, err = process.communicate()

    print(args)

    count = part[1].get('quantity', 1)
    output = ""
    if (process.returncode == 0):
        output += 'Finished generating: ' + folder + '/' + part_file_name
        for count in range(2, count + 1):
            part_copy_name = part[0] + '_' + str(count) + '.stl'
            shutil.copy(output_directory + part_file_name, output_directory + part_copy_name)
            output += '\nFinished generating: ' + folder + '/' + part_copy_name
    else:
        output += 'Failed to generate: ' + folder + '/' + part_file_name + ', Error: ' + str(err)
    return output

def print_parts(part_map):
    with ThreadPoolExecutor(max_workers = os.cpu_count()) as executor:
        print('Starting STL generation')
        futures = []
        for folder, part_group in flatten_to_folders_and_parts(part_map).items():
            output_directory = get_stl_output_directory() + folder + '/'
            for part in part_group.items():
                futures.append(executor.submit(generate_part, output_directory, folder, part))
        for future in futures:
            print(future.result())
        print('Done!')

print_parts(part_map)
