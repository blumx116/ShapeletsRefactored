import numpy as np
from sklearn.tree import DecisionTreeClassifier
from typing import Callable, Union

from utils.TensorUtils import (
    z_normalized_distance,
    euclidean_distance,
    matrix_min,
    sliding_window,
    matrix_argmin)
from data import Data


def binary_classify_1_decision_node(
        shapelet: np.ndarray,
        distance_threshold: float,
        training_data: Data,
        testing_data: Data,
        normalization_flag: bool = True) -> (np.ndarray, bool):
    """
    Classifies testing_data using the specified shapelet and distance_threshhold
    Uses training_data to decide which class is the class inside the circle
    :param shapelet: (m-length vector) representing the shapelet to be matched with
    :param distance_threshold: distance from the shapelet to split the classes
    :param training_data: data to use to decide which side of the split each class is
    :param testing_data: data to classify
    :param normalization_flag: whether to use z-normalization before distance
    :return: (i) class predictions (0,1),
    (ii) bool indicating if the in class is <= distance_threshold
    """
    assert distance_threshold >= 0
    if distance_threshold == 0:
        distance_threshold = 0.00005

    distance_func = z_normalized_distance if normalization_flag else euclidean_distance

    train_distances = matrix_min(
        sliding_window(training_data.x, (len(shapelet),)),
        lambda data: distance_func(data, shapelet))

    classification_1 = train_distances <= distance_threshold
    classification_2 = ~classification_1

    use_schema_1 = np.sum(abs(classification_1 - training_data.y)) < \
                   np.sum(abs(classification_2 - training_data.y))

    test_distances = matrix_min(
        sliding_window(testing_data.x, (len(shapelet),)),
        lambda data: distance_func(data, shapelet))

    test_preds = test_distances <= distance_threshold if use_schema_1 \
        else test_distances >= distance_threshold

    return test_preds, use_schema_1


def align_with_shapelet(
        data: Union[Data, np.ndarray],
        shapelet: np.ndarray,
        normalization_flag: bool = True,
        copy_y_values: bool = True) -> Union[Data, np.ndarray]:
    """
    Returns a new Data object where the observations (x) are the closest
    matching subseries to the shapelet
    :param data: Data to be converted. (x) changes, (y) remains unchanged
    :param shapelet: The shapelet to match against
    :param normalization_flag: Flag for whether or not to use z_normalization
    :param copy_y_values: Whether or not to create a copy of the (y) values for the returned Data object
    :return: a new Data object with the subsetted (x) values
    """
    input_as_Data_object = isinstance(data, Data)

    if input_as_Data_object:
        x = data.x
    else:
        x = data

    distance_func = z_normalized_distance if normalization_flag else euclidean_distance

    new_x = matrix_argmin(
        sliding_window(x, len(shapelet), ),
        lambda data: distance_func(data, shapelet))

    if input_as_Data_object:
        new_y = data.y.copy() if copy_y_values else data.y

        return Data(new_x, new_y, clean=False)
    else:
        return new_x


def find_best_distance_threshhold(
        data: Data,
        shapelet: np.ndarray,
        distance_func: Callable[[np.ndarray, np.ndarray], np.ndarray]) -> float:
    """
    Finds the optimal threshold to divide the classes based on their distance from the shapelet
    (uses Euclidean distance)
    :param data: The data to be divided
    :param shapelet: The shapelet to use for the distance metric
    :return: the optimal threshhold to divide the classes
    """
    distances = shapelet_distances(data.x, shapelet, distance_func=distance_func)
    return find_best_cutoff(distances, data.y)


def find_best_cutoff(
        values: np.ndarray,
        classes: np.ndarray) -> float:
    """
    Finds the best value to split a line of values to minimize class entropy
    :param values: vector of values to be split at cutoff
    :param classes: classes corresponding to each value
    :return: the optimal split point
    """
    tree = DecisionTreeClassifier(max_depth=1, criterion='entropy')
    tree.fit(values.reshape(-1, 1), classes)
    return tree.tree_.threshold[0]


def shapelet_distances(
        data: np.ndarray,
        shapelet: np.ndarray,
        distance_func: Callable[[np.ndarray, np.ndarray], np.ndarray] = euclidean_distance) -> np.ndarray:
    """
    Returns an n x 1 array of distances from the given shapelet according to distance metric
    :param data: n x k array, where n is the number of observations
    :param shapelet: l length vector, where l <= k, shapelet to be referenced for distance
    :param distance_func: function for evaluating distance. default: TensorUtils.euclidean_distance
    :return: np.ndarray containing the distances for each shapelet
    """
    assert data.shape[1] >= shapelet.shape[0], "data must have at least as many columns as shapelet"

    return matrix_min(
        sliding_window(data, (len(shapelet),)),
        lambda data: distance_func(data, shapelet))


def evaluate_accuracy(preds: np.ndarray, actual: np.ndarray) -> float:
    assert preds.size == actual.size, "Arrays must be of same size"

    return 100 * sum(preds == actual) / preds.size

