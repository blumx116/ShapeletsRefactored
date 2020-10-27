import os

import numpy as np

class CSVShapeletReader:
    def __init__(self, suffix:str="", prefix:str ="", sep: str=",", filetype: str=".csv"):
        self.suffix: str = suffix
        self.prefix: str = prefix
        self.sep: str = sep
        self.file_type: str = ".csv"

    def read_shapelets(self, filepath, filename):
        results = []
        with open(os.path.join(filepath, self.prefix + filename + self.suffix + self.file_type), "r") as f:
            for line in f:
                elements = line.split(sep=self.sep)
                if len(elements) != 0:
                    if elements[-1] == "\n": #last element is just newline character
                        elements = elements[:-1] #ignore the empty list element
                    else:
                        elements[-1]=elements[-1][:-1] #trim the newline character of of the last one
                    results.append(np.asarray(elements))
        return results

