import json
import shutil
import platform
import os
import sys
from functools import cache
from subprocess import Popen, PIPE
from pathlib import PurePath
from threading import Lock

conf_file_name = 'export.conf'
lock = Lock()

openSCADLocationName = 'openSCADLocation'
stlOutputDirectoryName = 'stlOutputDirectory'

def is_openscad_location_valid(location):
    return shutil.which(location) is not None

def is_path_writable(directory):
    return os.access(os.path.dirname(directory), os.W_OK)

def reprompt(validation_func, input_name):
    user_input = input('Enter {} or "q" to exit: '.format(input_name))
    while not validation_func(user_input) and user_input.strip() != 'q':
        print('{}: "{}" not accessible'.format(input_name, user_input))
        user_input = input('Enter {} or "q" to exit: '.format(input_name))
    if user_input == 'q':
        sys.exit('Quitting. {} must be set.'.format(input_name))
    else:
        return user_input

@cache
def _get_project_root():
    project_root = PurePath(__file__).parents[2]
    if not os.path.isdir(project_root):
        project_root = reprompt(os.path.isdir, 'project root folder')
    return str(project_root)

def _get_openscad_location():
    system = platform.system()
    location = ''
    if (system == 'Windows'):
        nightly_path = 'C:\\Program Files\\OpenSCAD (Nightly)\\openscad.exe'
        if (shutil.which(nightly_path) is not None):
            location = nightly_path
        else:
            location = 'C:\\Program Files\\OpenSCAD\\openscad.exe'
    elif (system == 'Darwin'):
        location = '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD.app'
    elif (system == 'Linux'):
        location = 'openscad'
    if not is_openscad_location_valid(location):
        reprompt(is_openscad_location_valid, 'OpenSCAD executable location')
    return location

def _get_stl_output_directory():
    default = os.path.join(os.path.expanduser('~'), 'Desktop', 'stl_export')
    directory = ''
    if is_path_writable(default):
        user_input = input('Would you like to use default STL output directory of {}? (y/n): '.format(default))
        if user_input.strip() == 'y':
            directory = default
    if not is_path_writable(directory):
        directory = reprompt(is_path_writable, 'STL output directory')
    return directory

@cache
def _get_manifold_support(openscad_location):
    if openscad_location:
        process = Popen([openscad_location, '-h'], stdout=PIPE, stderr=PIPE)
        _, out = process.communicate()
        return 'manifold' in str(out)
    else:
        return False

def validate_config(config):
    validated_config = config.copy()
    if not is_openscad_location_valid(config.get(openSCADLocationName, '')):
        validated_config[openSCADLocationName] = _get_openscad_location()
    if not is_path_writable(config.get(stlOutputDirectoryName, '')):
        validated_config[stlOutputDirectoryName] = _get_stl_output_directory()
    return validated_config

@cache
def get_config():
    conf_file = os.path.join(_get_project_root(), conf_file_name)
    config = {}
    if os.path.isfile(conf_file):
        with open(conf_file, 'r') as file:
            config = json.load(file)
    validated_config = validate_config(config)
    if validated_config != config:
        with open(conf_file, 'w') as file:
            json.dump(validated_config, file, indent=2)
    return validated_config

@cache
def get_project_root():
    with lock:
        return _get_project_root()

@cache
def get_openscad_location():
    with lock:
        return get_config()[openSCADLocationName]

@cache
def get_stl_output_directory():
    with lock:
        return get_config()[stlOutputDirectoryName]

@cache
def get_manifold_support():
    with lock:
        return _get_manifold_support(get_openscad_location())
