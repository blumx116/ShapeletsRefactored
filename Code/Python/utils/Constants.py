import os
from typing import Dict

"""
This file contains constants used throughout the shapelet codebase.
Currently, it consists of the following objects:

paths : a dictionary with the following keys:
   - "repo" : the absolute path of this project
   - "data" : the absolute path of the directory containing all data for this project
   - "code" : the absolute path of the directory containing all code for this proejct
   - "results" : the absolute path of the directory containing all results for this project
   - "python" : the absolute path of the directory containing all python code for this project
   
Running this file as main will create a file @ paths["repo"]/vars.sh defining all of these paths 
for the command prompt
"""

paths : Dict[str, str] = {}

def define_path(name: str, path: str) -> None:
    """
    Adds the path to the global paths variable
    :param name: the name for the stored path
    :param path: the path to be stored
    """
    if not os.path.exists(path):
        raise OSError(f"The following path does not exist but was added to Constants.paths : {path}")
    if name in paths.keys():
        raise KeyError(f"The following key already exists in paths : {name}")

    paths[name] = path

    if __name__ == "__main__":
        print(f"{name}: {path}")

define_path("repo", os.path.abspath(os.path.join(os.path.dirname(__file__), "../../..")))
define_path("data", os.path.join(paths["repo"], "Data"))
define_path("code", os.path.join(paths["repo"], "Code"))
define_path("results", os.path.join(paths["repo"], "Results"))
define_path("python", os.path.join(paths["code"], "Python"))

def export_paths(file: str) -> None:
    with open(file, "w") as f:
        for key in paths.keys():
            f.write(f"{key}={paths[key]}\n")


if __name__ == "__main__":
    export_paths(os.path.join(paths["code"], "vars.sh"))