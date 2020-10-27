import numpy as np
from typing import Callable, Union, Tuple


def euclidean_distance(observations: np.ndarray, reference: np.ndarray) -> np.ndarray:
    """
    Computes the euclidean distance between observations and reference
    If reference is a vector, it is subtracted from all observations
    :param observations: mxn matrix, where m is number of observations
    :param reference: mxn matrix or 1xn vector
    :return: array of euclidean distances between each element of observations and reference
    """
    return L2_magnitude(observations - reference, axis=observations.ndim - 1)


def L2_magnitude(vectors: np.ndarray, axis: int = 1) -> np.ndarray:
    """
    Returns an array representing the magnitude of the vectors along a specified axis
    NOTE: does not compute the L2 norm of the matrix itself
    :param vectors: The mxn array of vectors to be computed
    :param axis: The axis along which vectors are chosen. 0: columns, 1: rows
    :return: A vector of the distances (m if axis=1, n if axis=0)
    """

    return np.sqrt(np.sum(np.square(vectors), axis=axis))


def generate_sliding_window(a: np.ndarray, window_size: int, step_size: int = 1) -> np.ndarray:
    """
    Creates a new matrix by sliding a window across vector
    :param a: The vector to slide across
    :param window_size: The size of the window to be generated
    :param step_size: The step_size between each window
    :return: Matrix, where each row represents one instance of the window
    """
    shape = a.shape[:-1] + (a.shape[-1] - window_size + 1 - step_size, window_size)
    strides = np.asarray(a.strides) + (a.strides[-1] * step_size,)
    return np.lib.stride_tricks.as_strided(a, shape=shape, strides=strides)


def z_normalize(A: np.ndarray) -> np.ndarray:
    """
    Z-normalizes each row of A by subtracting by the mean of the row and dividing by its stdev
    :param A: Matrix to be normalized
    :return: New matrix where each entry is z-normalized
    """
    mean = np.expand_dims(A.mean(axis=A.ndim - 1), -1)
    std = np.expand_dims(A.std(axis=A.ndim - 1), -1)
    std[std == 0] = 1  # set std to 1 when it is 0 to avoid division by 0
    return (A - mean) / std


def z_normalized_distance(observations: np.ndarray, reference: np.ndarray) -> np.ndarray:
    """
    Returns the euclidean distance between each row of observations and reference after z-normalization
    :param observations: mxn array of n-length observations
    :param reference: 1xn or mxn vector(s) to compute the distance from
    :return: m-length vector representing each length
    """
    return euclidean_distance(z_normalize(observations), z_normalize(reference))


def select_closest_subsequence(
        time_series: np.ndarray,
        reference: np.ndarray,
        distance_func: Callable[[np.ndarray, np.ndarray], np.ndarray]) -> np.ndarray:
    """
    Finds the closest subsequence of time_series to the reference as measured by distance_func
    :param time_series: 1xn array representing the time series to be classified from
    :param reference: the 1xm array representing the sequence to match with
    :param distance_func: A function taking in an (n-m+1)xm matrix and a 1xm vector mapping to a (n-m+1)-length vector
    :return: The m-length vector representing the closest match to reference in time_series
    """
    subsequences = generate_sliding_window(time_series, window_size=len(reference))
    return matrix_argmin(subsequences, lambda data: distance_func(data, reference))


def minimum_distance(
        time_series: np.ndarray,
        reference: np.ndarray,
        distance_func: Callable[[np.ndarray, np.ndarray], np.ndarray]) -> float:
    """
    Find the minimum distance between subseries of time_series and reference
    (m-length vector, m <= n) according to distance_func
    :param time_series: (n-length vector) to select subseries of
    :param reference: (m-length vector, m <= n) vector to match to
    :param distance_func: function ((kxn),(n,)) => (k,) mapping each row to distance from
    each row of the first argument to the second argument. Returns k-length vector of distances
    :return: The minimum distance returned by distance_func
    """
    subsequences = generate_sliding_window(time_series, window_size=len(reference))
    return matrix_min(subsequences, lambda data: distance_func(data, reference))


def matrix_argmin(A: np.ndarray, func: Callable[[np.ndarray], np.ndarray]) -> np.ndarray:
    """
    Selects the row of matrix A that maximizes func
    TODO: expand to work on multiple axes
    :param A: The mxn matrix to be selected from
    :param func: a function from (mxn) => (mx1) to choose the minimum from
    :return: The row of A that minimized func
    """
    scores = func(A)
    min_rows = np.argmin(scores, axis=1)

    # generate the indexer to select the best rows
    indices = list([np.arange(len(min_rows)) for _ in range(A.ndim)])
    indices[-1] = slice(None)
    indices[-2] = min_rows

    return A[tuple(indices)]


def matrix_min(A: np.ndarray, func: Callable[[np.ndarray], np.ndarray]) -> Union[float, np.ndarray]:
    """
    Returns the minimum value obtained by applying func to A
    :param A: mxn matrix to maximize over
    :param func: a function from (mxn) => (mx1) to choose the minimum from
    :return:  The minimum value in the vector returned by func
    """
    scores = func(A)
    return np.min(scores, axis=1)


def one_hot(values: np.ndarray, n_possible_values: int = None) -> np.ndarray:
    """
    Creates a one-hot tensor with k+1 dimensions, where 'values' has k dimensions
    Each corresponding 'row' has all 0's except for a 1 corresponding to
    the associated number in values
    :param values: tensor of ints to be converted to one-hot
    :param n_possible_values: length of each row. Must be greater than the highest
    value of values
    :return: A K+1 dimensional tensor of 1's and 0's
    """
    if n_possible_values is None:
        n_possible_values = np.max(values)

    assert (np.all(values >= 0))
    assert (np.all(values < n_possible_values))

    return np.eye(n_possible_values)[values].astype(dtype=int)


def circular_projection(A: np.ndarray, axis: int = 1, axis_aligned: bool = True) -> np.ndarray:
    """
    Concatenates A with the square of A along hte specified existing axis
    Equivalent to projecting a linear space to a quadratic space
    TODO: not axis_aligned case only works correctly for mx2 matrices along axis 1
    :param A: The matrix to be projected
    :param axis: The axis to concatenate along
    :return: A new matrix representing the concatenated values
    """
    result = np.concatenate([A, np.square(A)], axis=axis)

    if not axis_aligned:
        assert (A.ndim == 2)
        assert (A.shape[1] == 2)
        assert (axis == 1)
        appendix = A[:, 0] * A[:, 1]
        result = np.concatenate([result, appendix], axis=axis)

    return result


def sliding_window(array: np.ndarray,
                   window: Union[Tuple[int], int] = (0,),
                   asteps: Tuple[int] = None,
                   wsteps: Union[Tuple[int], int] = None,
                   axes: Union[Tuple[int], int] = None,
                   toend: bool = True) -> np.ndarray:
    """Create a view of `array` which for every point gives the n-dimensional
    neighbourhood of size window. New dimensions are added at the end of
    `array` or after the corresponding original dimension.

    Code courtesy of https://gist.github.com/seberg/3866040

    Parameters
    ----------
    array : array_like
        Array to which the rolling window is applied.
    window : int or tuple
        Either a single integer to create a window of only the last axis or a
        tuple to create it for the last len(window) axes. 0 can be used as a
        to ignore a dimension in the window.
    asteps : tuple
        Aligned at the last axis, new steps for the original array, ie. for
        creation of non-overlapping windows. (Equivalent to slicing result)
    wsteps : int or tuple (same size as window)
        steps for the added window dimensions. These can be 0 to repeat values
        along the axis.
    axes: int or tuple
        If given, must have the same size as window. In this case window is
        interpreted as the size in the dimension given by axes. IE. a window
        of (2, 1) is equivalent to window=2 and axis=-2.
    toend : bool
        If False, the new dimensions are right after the corresponding original
        dimension, instead of at the end of the array. Adding the new axes at the
        end makes it easier to get the neighborhood, however toend=False will give
        a more intuitive result if you view the whole array.

    Returns
    -------
    A view on `array` which is smaller to fit the windows and has windows added
    dimensions (0s not counting), ie. every point of `array` is an array of size
    window.

    Examples
    --------
    >>> a = np.arange(9).reshape(3,3)
    >>> sliding_window(a, (2,2))
    array([[[[0, 1],
             [3, 4]],
            [[1, 2],
             [4, 5]]],
           [[[3, 4],
             [6, 7]],
            [[4, 5],
             [7, 8]]]])

    Or to create non-overlapping windows, but only along the first dimension:
    >>> sliding_window(a, (2,0), asteps=(2,1))
    array([[[0, 3],
            [1, 4],
            [2, 5]]])

    Note that the 0 is discared, so that the output dimension is 3:
    >>> sliding_window(a, (2,0), asteps=(2,1)).shape
    (1, 3, 2)

    This is useful for example to calculate the maximum in all (overlapping)
    2x2 submatrixes:
    >>> sliding_window(a, (2,2)).max((2,3))
    array([[4, 5],
           [7, 8]])

    Or delay embedding (3D embedding with delay 2):
    >>> x = np.arange(10)
    >>> sliding_window(x, 3, wsteps=2)
    array([[0, 2, 4],
           [1, 3, 5],
           [2, 4, 6],
           [3, 5, 7],
           [4, 6, 8],
           [5, 7, 9]])
    """
    array = np.asarray(array)
    orig_shape = np.asarray(array.shape)
    window = np.atleast_1d(window).astype(int)  # maybe crude to cast to int...

    if axes is not None:
        axes = np.atleast_1d(axes)
        w = np.zeros(array.ndim, dtype=int)
        for axis, size in zip(axes, window):
            w[axis] = size
        window = w

    # Check if window is legal:
    if window.ndim > 1:
        raise ValueError("`window` must be one-dimensional.")
    if np.any(window < 0):
        raise ValueError("All elements of `window` must be larger then 1.")
    if len(array.shape) < len(window):
        raise ValueError("`window` length must be less or equal `array` dimension.")

    _asteps = np.ones_like(orig_shape)
    if asteps is not None:
        asteps = np.atleast_1d(asteps)
        if asteps.ndim != 1:
            raise ValueError("`asteps` must be either a scalar or one dimensional.")
        if len(asteps) > array.ndim:
            raise ValueError("`asteps` cannot be longer then the `array` dimension.")
        # does not enforce alignment, so that steps can be same as window too.
        _asteps[-len(asteps):] = asteps

        if np.any(asteps < 1):
            raise ValueError("All elements of `asteps` must be larger then 1.")
    asteps = _asteps

    _wsteps = np.ones_like(window)
    if wsteps is not None:
        wsteps = np.atleast_1d(wsteps)
        if wsteps.shape != window.shape:
            raise ValueError("`wsteps` must have the same shape as `window`.")
        if np.any(wsteps < 0):
            raise ValueError("All elements of `wsteps` must be larger then 0.")

        _wsteps[:] = wsteps
        _wsteps[window == 0] = 1  # make sure that steps are 1 for non-existing dims.
    wsteps = _wsteps

    # Check that the window would not be larger then the original:
    if np.any(orig_shape[-len(window):] < window * wsteps):
        raise ValueError("`window` * `wsteps` larger then `array` in at least one dimension.")

    new_shape = orig_shape  # just renaming...

    # For calculating the new shape 0s must act like 1s:
    _window = window.copy()
    _window[_window == 0] = 1

    new_shape[-len(window):] += wsteps - _window * wsteps
    new_shape = (new_shape + asteps - 1) // asteps
    # make sure the new_shape is at least 1 in any "old" dimension (ie. steps
    # is (too) large, but we do not care.
    new_shape[new_shape < 1] = 1
    shape = new_shape

    strides = np.asarray(array.strides)
    strides *= asteps
    new_strides = array.strides[-len(window):] * wsteps

    # The full new shape and strides:
    if toend:
        new_shape = np.concatenate((shape, window))
        new_strides = np.concatenate((strides, new_strides))
    else:
        _ = np.zeros_like(shape)
        _[-len(window):] = window
        _window = _.copy()
        _[-len(window):] = new_strides
        _new_strides = _

        new_shape = np.zeros(len(shape) * 2, dtype=int)
        new_strides = np.zeros(len(shape) * 2, dtype=int)

        new_shape[::2] = shape
        new_strides[::2] = strides
        new_shape[1::2] = _window
        new_strides[1::2] = _new_strides

    new_strides = new_strides[new_shape != 0]
    new_shape = new_shape[new_shape != 0]

    return np.lib.stride_tricks.as_strided(array, shape=new_shape, strides=new_strides)