from datetime import date, datetime
import os
from typing import Union


from utils.Constants import paths

class OutputHelper:
    def __init__(self, readme_text: str, date: Union[date, datetime] = None):
        if date is None:
            date = date.today()
        self.output_dir = os.path.join(paths["results"], str(date))

        if os.path.exists(paths["results"]):
            if not os.path.exists(self.output_dir):
                os.mkdir(self.output_dir)

        self.readme_txt = os.path.join(self.output_dir, "readme.txt")

        with open(self.readme_txt, "w") as f:
            f.write(readme_text)
