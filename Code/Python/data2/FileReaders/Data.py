import numpy as np

class Data:
    def __init__(self, raw: np.ndarray, y_values: np.ndarray = None, clean = True):
        if y_values is None:
            y_values = raw[:, 0]
            x_values = raw[:, 1:]
        else:
            x_values = raw

        assert y_values.shape[0] == x_values.shape[0]

        self.x = x_values
        self.y = standardize_labels(y_values) if clean else y_values

    def copy(self):
        return Data(self.x, self.y)

    def deepcopy(self):
        return Data(self.x.copy(), self.y.copy())

    def count(self) -> int:
        return self.x.shape[0]

def standardize_labels(labels: np.ndarray, key: np.ndarray = None):
    if key is None:
        key = np.unique(labels) #always the same because is sorted

    f = np.vectorize(lambda label: np.argwhere(key == label)[0])
    return f(labels)