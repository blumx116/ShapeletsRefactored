from .FileReader import FileReader
from .Data import Data

class DefaultReader(FileReader):
    def __init__(self, type: str ="commas", prune_ending: str = "auto"):
        if type == "commas":
            self.file_type = "csv"
            self.sep = ","
        elif type == "commas+":
            self.file_type = "csv"
            self.sep = ", "
        elf type == ""
