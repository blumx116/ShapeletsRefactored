from typing import Union
from datetime import date, datetime
import os


from results import OutputHelper

class SingleFileOutput(OutputHelper):
    def __init__(self, readme_txt: str, date: Union[date, datetime] = None,
                 output_file: str = "results.txt",
                 log_file: str = "log.txt"):
        super().__init__(readme_txt, date)
        self.output_file = open(os.path.join(self.output_dir, "results.txt"), "w")
        self.log_file = open(os.path.join(self.output_dir, "log.txt"), "w")

    def get_log(self, dataset: str) -> "file":
        return self.log_file

    def get_output(self, dataset: str) -> "file":
        return self.output_file