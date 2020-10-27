import os
from typing import List

import numpy as np

from data import FileStructureReader, Data

class DatasetReader:
    def __init__(self, reader: FileStructureReader):
        self.reader: FileStructureReader = reader
        self.file_type : str = ".csv"
        self.sep : str = ","
        self.datapath : str = reader.datapath

    def _get_name(self, dataset: str, type:str) -> str:
        suffix = "_TRAIN" if type == "train" else ("_TEST" if type == "test" else "")
        return dataset + suffix + self.file_type

    def _load_data(self, dataset: str, type: str):
        return Data(
            np.genfromtxt(
                os.path.join(self.reader.get_folder(dataset), self._get_name(dataset, type))))

    def training_data(self, dataset: str) -> Data:
        return self._load_data(dataset, type="train")

    def test_data(self, dataset: str) -> Data:
        return self._load_data(dataset, type="test")

    def datasets(self) -> List[str]:
        return self.reader.datasets()
