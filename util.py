import itertools
from typing import Iterable


def pairwise(iterable: Iterable):
    """s -> (s0,s1), (s1,s2), (s2, s3), ..."""
    a, b = itertools.tee(iterable)
    next(b, None)
    return zip(a, b)


def n_wise(iterable, n=1):
    iterators = itertools.tee(iterable, n)
    for i in range(n):
        for _ in range(i):
            next(iterators[i], None)
    return zip(*iterators)


def first(iterable, *, default=..., condition=None):
    condition = condition or (lambda x: True)
    try:
        return next(x for x in iterable if condition(x))
    except StopIteration:
        if default is ...:
            raise
        return default
