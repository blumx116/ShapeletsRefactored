from data2 import Data
from typing import List, Union, Iterable

class DataReader:
    def __init__(self,
                 datapath: str,
                 file_prefix: str = "",
                 file_suffix: str = "",
                 file_type: str = ".csv",
                 ignore: Iterable[str] = []):
        self.file_prefix = file_prefix
        self.file_suffix = file_suffix
        self.file_type = file_type
        self.datapath = datapath
        self.ignore = set(ignore)



    def datasets(self) -> List[str]:
        raise NotImplementedError("DataReader is an abstract class. datasets() not implemented.")

    def load_train_data(self, dataset_name: str) -> Data:
        raise NotImplementedError("DataReader is an abstract class. load_train_data() not implemented")

    def load_test_data(self, dataset_name: str) -> Data:
        raise NotImplementedError("DataReader is an abstract class. load_test_data() not implemented")


