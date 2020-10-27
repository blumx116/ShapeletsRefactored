import os
from typing import Callable, List

import numpy as np

from data import DatasetReader

class OptimizedDataLoader:
    def __init__(self, reader: DatasetReader):
        self.reader : DatasetReader = reader
        self.metric : Callable[[int, int], float] = lambda n, m: (n**2) * (m**3)

    def load_dataset_order(self, log_file: str) -> List[str]:
        log_path = self.dataset_log_path(log_file)
        datasets: List[str] = self.reader.datasets()

        if os.path.isfile(log_path):
            with open(log_path, "r") as f:
                result = f.readlines()
                result = list(map(lambda s: s[:-1] if s[-1]=="\n" else s, result))
            if set(datasets) == set(result):
                return result
            else:
                raise LookupError(f"The results in {log_path} are out of date")
        else:
            raise FileNotFoundError(f"The file {log_path} was not found and could not be read from")

    def dataset_log_path(self, log_file: str):
        return os.path.join(self.reader.datapath, log_file)

    def ordered_datasets(self, log_file: str="datasetorder.txt") -> List[str]:

        datasets: List[str] = self.reader.datasets()

        if log_file is not None:
            try:
                return self.load_dataset_order(log_file)
            except LookupError as e:
                pass
            except FileNotFoundError as e:
                pass

        rankings = []
        for dataset in datasets:
            data = self.reader.training_data(dataset)
            rankings.append(self.metric(data.x.shape[0], data.x.shape[1]))
        result = np.asarray(datasets)
        result = result[np.argsort(rankings)]

        if log_file is not None:
            with open(self.dataset_log_path(log_file), "w") as f:
                for dataset in result:
                    f.write(f"{dataset}\n")

        return result

if __name__ == "__main__":
    from data import UCRDataReader
    ucr = UCRDataReader()
    optim = OptimizedDataLoader(ucr)
    print(optim.ordered_datasets())
