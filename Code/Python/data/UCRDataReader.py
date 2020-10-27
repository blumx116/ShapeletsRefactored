import os

from data import DatasetReader, FileStructureReader
from utils.Constants import paths

class UCRDataReader(DatasetReader):
    def __init__(self):
        super().__init__(FileStructureReader(os.path.join(paths["data"], "UCRArchive_2018")))
        self.sep : str = "\t"
        self.file_type : str = ".tsv"





if __name__ == "__main__":
    ucr = UCRDataReader()
    print(ucr.datasets())