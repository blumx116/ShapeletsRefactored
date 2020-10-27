import os
from datetime import date, datetime
from typing import Union

from results import OutputHelper

class MultiFolderOutput(OutputHelper):
    def __init__(self, readme_txt: str, date: Union[date, datetime] = None):
        super().__init__(readme_txt, date)
        self.current_dataset = None

    def _get_subdirectory(self, dataset: str) -> str:
        subdir = os.path.join(self.output_dir, dataset)
        if os.path.exists(subdir):
            assert os.path.isdir(subdir)
            return subdir
        else:
            os.mkdir(subdir)
            return subdir

    def _open_files(self, dataset: str) -> None:
        if self.current_dataset != dataset:
            subdir = self._get_subdirectory(dataset)
            self.current_dataset = dataset
            self.log_file = open(os.path.join(subdir, "results.txt"))
            self.output_file = open(os.path.join(subdir, "log.txt"))

    def get_log(self, dataset: str) -> "file":
        self._open_files(dataset)
        return self.log_file

    def get_output(self, dataset: str) -> "file":
        self._open_files(dataset)
        return self.output_file

