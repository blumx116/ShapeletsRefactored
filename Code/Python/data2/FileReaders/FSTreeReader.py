from data2.FileReaders.FileReader import FileReader
from typing import NamedTuple, List
import numpy as np
import re
from math import floor
from typing import List

ShapeletTree = NamedTuple("ShapeletTree", [
    ("IDs", List[int]),
    ("shapelets", List[np.ndarray]),
    ("thresholds", List[float])])

class FSShapeletTreeReader(FileReader[ShapeletTree]):
    def __init__(self):
        self.file_type = "txt"



    def extract_root_shapelet_from_file(self, fileName: str) -> (List[float], float):
        shapelet_IDs, Shapelets, Distances = self.extract_shapelet_tree_from_file(fileName)
        assert (len(Shapelets) > 0)
        assert (len(Distances) > 0)
        return (Shapelets[0], Distances[0])

    def extract_shapelet_tree_from_file(self, fileName: str) -> (List[float], List[np.ndarray], List[float]):
        with open(fileName, 'r') as f:
            file_text = f.read()

        node_info = re.findall('[NonLeaf]{4} [^\n]*[\n]', file_text)
        num_nodes = len(node_info)

        node_IDs = [0 for _ in range(num_nodes)]
        NonL_node_object_number = np.zeros(num_nodes)
        NonL_node_position = np.zeros(num_nodes)
        NonL_node_length = np.zeros(num_nodes)
        NonL_node_distance_threshold = np.zeros(num_nodes)
        NonL_node_training_split = [None for _ in range(num_nodes)]
        Leaf_node_classes = np.zeros(num_nodes)
        node_IDs_matlab_parent_style = np.zeros(num_nodes)
        partitions = [None for _ in range(num_nodes)]

        for i in range(num_nodes):
            if len(re.findall('NonL', node_info[i])) == 1:
                NonLeaf_numbers = re.findall('[.\d]+', node_info[i])

                node_IDs[i] = float(NonLeaf_numbers[0])
                NonL_node_object_number[i] = float(NonLeaf_numbers[1]) + 1
                NonL_node_position[i] = float(NonLeaf_numbers[2]) + 1
                NonL_node_length[i] = float(NonLeaf_numbers[3])
                NonL_node_distance_threshold[i] = float(NonLeaf_numbers[4])
                NonL_node_training_split[i] = re.findall('==>[^\n]+[\n]', node_info[i])[0]  # should this have 0?
                partitions[i] = self.extract_shapelet_partitions(NonL_node_training_split[i])
            else:
                node_info[i] = node_info[i][4:]

                node_numbers = re.findall('[\d]+', node_info[i])

                assert len(node_numbers) == 2, "Expected 2 node numbers"

                node_IDs[i] = float(node_numbers[0])
                Leaf_node_classes[i] = float(node_numbers[1])

        for i in range(num_nodes):
            parent_ID = floor(node_IDs[i] / 2)

            node_IDs_matlab_parent_style[i] = node_IDs.index(parent_ID) if parent_ID != 0 else 0

        # shapelet_info = re.findall('Shapelet [^a-zA-z\n]* (?:nan)? [^a-zA-z\n]*[[\n]', file_text)
        # couldn't get it to accept regex with nans

        shapelet_IDs = []
        shapelets = []

        file_lines = file_text.split("\n")
        for line in file_lines:
            if line.startswith("Shapelet"):
                line_split = list(filter(lambda s: s != "", line.split(" ")))[
                             1:]  # ignore the shapelet bit at the start
                if np.all(map(lambda s: try_convert(s, np.NaN, float) or s == "nan", line_split)):
                    shapelet_IDs.append(int(line_split[0]))
                    shapelets.append(
                        np.asarray(list(map(lambda s: float(s) if s != "nan" else np.NaN, line_split[1:])))
                    )

        """"
        num_shapelets = len(shapelet_info)

        shapelet_IDs = np.zeros(num_shapelets)
        shapelets = [None for _ in range(num_shapelets)]

        for i in range(num_shapelets):
            shapelet_info[i] = shapelet_info[i][8:]

            shapelet = map(lambda char: try_convert(char, np.NaN, float), shapelet_info[i].split())
            shapelet = list(filter(lambda num: not np.isnan(num), shapelet))

            shapelet_IDs[i] = shapelet[0]
            shapelets[i] = np.asarray(shapelet[1:], np.float32)
        """

        return shapelet_IDs, shapelets, NonL_node_distance_threshold

    @staticmethod
    def try_convert(value, default, *types):
        for t in types:
            try:
                return t(value)
            except:
                continue
        return default

    def extract_shapelet_partitions(string_partition: str):
        partitions = string_partition.split('/')

        assert len(partitions) == 2, "Partitions should be of length 2"

        partitions = map(
            str.split,
            partitions)

        partitions = map(
            lambda partition:
            map(
                lambda substr: try_convert(substr, np.NaN, float),
                partition),
            partitions)

        partitions = list(map(
            lambda partition:
            list(filter(lambda num: not np.isnan(num), partition)),
            partitions))

        return partitions