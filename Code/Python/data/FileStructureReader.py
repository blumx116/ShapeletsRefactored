import os
from typing import List

import numpy as np

class FileStructureReader:
    def __init__(self, datapath: str):
        assert os.path.isdir(datapath)
        self.datapath = datapath
        self.folder_suffix = ""
        self.folder_prefix = ""

    def datasets(self) -> List[str]:
        return [self._convert_folder_format(result) for result in os.listdir(self.datapath)
                if self._folder_matches_format(result) and os.path.isdir(os.path.join(self.datapath, result))]

    def get_folder(self, dataset: str) -> str:
        assert dataset in self.datasets()
        return os.path.join(self.datapath, self.folder_prefix + dataset + self.folder_suffix)

    def _prefix_matches(self, name: str, prefix: str) -> bool:
        if len(prefix) > len(name):
            return False
        return name[:len(prefix)] == prefix

    def _suffix_matches(self, name: str, suffix: str) -> bool:
        if suffix == "":
            return True
        if len(suffix) > len(name):
            return False
        return name[-len(suffix):] == suffix

    def _remove_prefix(self, name: str, prefix: str) -> str:
        if self._prefix_matches(name, prefix):
            return name[len(prefix):]
        else:
            raise Exception(f"Cannot remove prefix {prefix} from {name}")

    def _remove_suffix(self, name: str, suffix: str) -> str:
        if suffix == "":
            return name
        if self._prefix_matches(name, suffix):
            return name[:-len(suffix)]
        else:
            raise Exception(f"Cannot remove prefix {suffix} from {name}")

    def _folder_matches_format(self, name: str) -> bool:
        return self._prefix_matches(name, self.folder_prefix) and self._suffix_matches(name, self.folder_suffix)

    def _convert_folder_format(self, name: str) -> str:
        try:
            return self._remove_prefix(self._remove_suffix(name, self.folder_suffix), self.folder_prefix)
        except Exception as e:
            raise e