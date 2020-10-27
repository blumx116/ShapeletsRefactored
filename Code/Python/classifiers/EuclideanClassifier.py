import numpy as np
from sklearn.tree import DecisionTreeClassifier
from typing import Callable, Union
from utils.Heuristics import information_gain

from utils.TensorUtils import (
    z_normalized_distance,
    euclidean_distance,
    matrix_min,
    sliding_window,
    matrix_argmin)
from data import Data

class ShapeletNode:
    def __init__(self, shapelet: np.ndarray, threshold: float = None, normalization_flag: bool = True, use_schema_1: bool = None):
        self.threshold = threshold
        self.distance_func = z_normalized_distance if normalization_flag else euclidean_distance()
        self.use_schema_1 = use_schema_1
        self.shapelet = shapelet

    def fit(self, train: Data) -> "ShapeletNode":
        train_distances = matrix_min(
            sliding_window(train.x, (len(self.shapelet),)),
            lambda data: self.distance_func(data, self.shapelet))

        if self.threshold is None:
            self._fit_distance_threshold(train_distances, train.y)

        if self.use_schema_1 is None:
            self._fit_schema(train_distances, train.y)

        return self

    def predict(self, data: np.ndarray) -> np.ndarray:
        assert self.use_schema_1 is not None
        assert self.threshold is not None

        distances = matrix_min(
            sliding_window(data, (len(self.shapelet),)),
            lambda data: self.distance_func(data, self.shapelet))

        classification = distances <= self.threshold if self.use_schema_1 \
            else self.distances >= self.threshold

        return np.asarray(classification, dtype=int)

    def _fit_distance_threshold(self, train_distances: np.ndarray, labels: np.ndarray) -> "ShapeletNode":
        tree = DecisionTreeClassifier(max_depth=1, criterion='entropy')
        tree.fit(train_distances.reshape(-1, 1), labels)
        self.threshold =  tree.tree_.threshold[0]

    """
    def _fit_distance_threshold(self, train_distances: np.ndarray, labels: np.ndarray) -> "ShapeletNode":
        values = sorted(train_distances)
        def get_split_entropy(value):
            split = train_distances <= value
            return information_gain(labels, split, format="confusion")

        IGs = list(map(get_split_entropy, values))
        optimal_split = values[np.argmax(IGs)]

        self.threshold = optimal_split
        return self
    """

    def _fit_schema(self, train_distances: np.ndarray, labels: np.ndarray) -> "ShapeletNode":
        classification_1 = train_distances <= self.threshold
        classification_2 = ~classification_1

        use_schema_1 = np.sum(abs(classification_1 - labels)) < \
                       np.sum(abs(classification_2 - labels))

        self.use_schema_1 = use_schema_1

