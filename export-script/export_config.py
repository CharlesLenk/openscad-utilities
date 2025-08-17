import json
import shutil
import platform
import os
import sys
from functools import cache
from subprocess import Popen, PIPE
from pathlib import PurePath

conf_file_name = 'export config.json'
default_export_file_name = 'export map.scad'
default_parts_file_name = 'export parts.json'

openSCADLocationName = 'openSCADLocation'
projectRootName = 'projectRoot'
exportFilePathName = 'exportFilePath'
exportPartsFilePathName = 'exportPartsFilePath'
stlOutputDirectoryName = 'stlOutputDirectory'

def is_openscad_location_valid(location):
    return shutil.which(location) is not None

def is_path_writable(directory):
    return os.access(os.path.dirname(directory), os.W_OK)

def get_file_path(search_directory, file_name):
    for root, dirs, files in os.walk(search_directory):
        if file_name in files:
            return str(os.path.join(root, file_name))

def is_file_with_extension(file_name, extension, search_directory):
    return file_name.lower().endswith(extension) and get_file_path(search_directory, file_name) is not None

def yes_no_prompt(message):
    valid_inputs = ('y', 'n')
    response = input(message + ' (y/n): ')
    while response.lower() not in valid_inputs:
        print('{} not valid. Enter one of: {}'.format(response, valid_inputs))
        response = input(message)
    return response.lower() == 'y'

def reprompt(validation_func, input_name, default, extra_validate_args = []):
    input_value = None
    print('\nAttempting to load default {}: {}'.format(input_name, default))
    if validation_func(*([default] + extra_validate_args)):
        if yes_no_prompt('Default {} ({}) is valid. Would you like to use it?'.format(input_name, default)):
            input_value = default
    else:
        print('Unable to load default {}'.format(input_name))

    if (input_value is None):
        input_value = input('Enter {} or "q" to exit: '.format(input_name))
        while not validation_func(*([input_value] + extra_validate_args)) and input_value.strip().lower() != 'q':
            print('{}: "{}" invalid or not accessible.'.format(input_name, input_value))
            input_value = input('Enter {} or "q" to exit: '.format(input_name))
        if input_value == 'q':
            sys.exit('Quitting. {} must be set.'.format(input_name))
    return input_value

def _get_project_root():
    process = Popen(['git', 'rev-parse', '--show-superproject-working-tree'], cwd=str(PurePath(__file__).parents[1]), stdout=PIPE, stderr=PIPE)
    project_root, err = process.communicate()
    project_root = str(project_root, encoding='UTF-8').strip()
    return reprompt(os.path.isdir, 'project root folder', project_root)

def _get_export_file_path(search_directory):
    export_file_name = reprompt(is_file_with_extension, 'export file (.scad)', default_export_file_name, ['.scad', search_directory])
    return get_file_path(search_directory, export_file_name)

def _get_export_parts_file(search_directory):
    export_parts_file_name = reprompt(is_file_with_extension, 'exports parts definition (.json)', default_parts_file_name, ['.json', search_directory])
    return get_file_path(search_directory, export_parts_file_name)

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
        location = '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'
    elif (system == 'Linux'):
        location = 'openscad'
    return reprompt(is_openscad_location_valid, 'OpenSCAD executable location', location)

def _get_stl_output_directory():
    default = os.path.join(os.path.expanduser('~'), 'Desktop', 'stl_export')
    return reprompt(is_path_writable, 'STL output directory', default)

def _get_manifold_support(openscad_location):
    if openscad_location:
        process = Popen([openscad_location, '-h'], stdout=PIPE, stderr=PIPE)
        _, out = process.communicate()
        return 'manifold' in str(out)
    else:
        return False

class ExportConfig:

    def persist(self):
        config = {}

        config[openSCADLocationName] = self.openSCADLocation
        config[projectRootName] = self.projectRoot
        config[exportFilePathName] = self.exportFilePath
        config[exportPartsFilePathName] = self.exportPartsFilePath
        config[stlOutputDirectoryName] = self.stlOutputDirectory
        conf_file = os.path.join(PurePath(__file__).parents[0], conf_file_name) 
        with open(conf_file, 'w') as file:
            json.dump(config, file, indent=2)

    def validate(self):
        if not is_openscad_location_valid(self.openSCADLocation):
            self.openSCADLocation = _get_openscad_location()
            self.persist()
        if not os.path.isdir(self.projectRoot):
            self.projectRoot = _get_project_root()
            self.persist()
        if not os.path.isfile(self.exportFilePath):
            self.exportFilePath = _get_export_file_path(self.projectRoot)
            self.persist()
        if not os.path.isfile(self.exportPartsFilePath):
            self.exportPartsFilePath = _get_export_parts_file(self.projectRoot)
            self.persist()
        if not is_path_writable(self.stlOutputDirectory):
            self.stlOutputDirectory = _get_stl_output_directory()
            self.persist()
    
    def __init__(self):
        conf_file = os.path.join(PurePath(__file__).parents[0], conf_file_name)
        config = {}
        if os.path.isfile(conf_file):
            with open(conf_file, 'r') as file:
                config = json.load(file)

        self.openSCADLocation = config.get(openSCADLocationName, '')
        self.projectRoot = config.get(projectRootName, '')
        self.exportFilePath = config.get(exportFilePathName, '')
        self.exportPartsFilePath = config.get(exportPartsFilePathName, '')
        self.stlOutputDirectory = config.get(stlOutputDirectoryName, '')
        self.validate()

        self.manifoldSupport = _get_manifold_support(self.openSCADLocation)
        with open(self.exportPartsFilePath, 'r') as file:
            self.partsMap = json.load(file)
