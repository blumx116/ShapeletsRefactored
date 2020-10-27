import os
from typing import List

import numpy as np

from utils.Constants import paths
from data.FileStructureReader import FileStructureReader
from data.CSVShapeletReader import CSVShapeletReader

class STShapeletReader(FileStructureReader):
    def __init__(self):
        super().__init__(os.path.join(paths["data"], "Shapelet_Transform_Results/Results_Normalized/ST/Predictions"))
        self.loader = CSVShapeletReader()

    def load_shapelets(self, dataset: str) -> List[np.ndarray]:
        assert dataset in self.datasets()
        results = self.loader.read_shapelets(self.get_folder(dataset), "shapelets0")
        #first 7 lines are useless data
        return results[7:]