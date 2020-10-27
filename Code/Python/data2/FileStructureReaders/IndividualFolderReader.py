from typing import Iterable, List
from data2 import DataReader
import os
from os import path

class IndividualFolderDataReader(DataReader):
    def __init__(self,
                 datapath :str,
                 folder_prefix: str = "",
                 folder_suffix: str= "",
                 file_prefix: str = "",
                 file_suffix: str = "",
                 train_suffix: str = "_TRAIN",
                 test_suffix: str = "_TEST",
                 file_type: str = ".csv",
                 ignore: Iterable[str] = []):

        super().__init__(datapath, file_prefix, file_suffix, train_suffix, test_suffix, file_type, ignore)

        self.folder_prefix = folder_prefix
        self.folder_suffix = folder_suffix

    def datasets(self) -> List[str]:
        folders = set(os.listdir(self.datapath))
        folders = list(folders - self.ignore)
        folders = filter(lambda folder: self._matches_pattern(folder, self.folder_prefix, self.folder_suffix),
                      folders)
        datasets = map(lambda folder:
                            self._remove_prefixes_suffixes(folder, self.folder_prefix, self.folder_suffix),
                       folders)
        return list(datasets)

    def _get_data_path(self, dataset_name: str):







