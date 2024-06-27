import git
import os

script_path = os.getcwd()
ea_path = os.path.abspath(os.path.join(script_path, "../../Experts/TimmyMaker"))
g = git.cmd.Git(ea_path)
g.pull()