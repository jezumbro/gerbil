import itertools
from typing import Iterable


def pairwise(iterable: Iterable):
    """s -> (s0,s1), (s1,s2), (s2, s3), ..."""
    a, b = itertools.tee(iterable)
    next(b, None)
    return zip(a, b)


def first(iterable, *, default=..., condition=None):
    condition = condition or (lambda x: True)
    try:
        return next(x for x in iterable if condition(x))
    except StopIteration:
        if default is ...:
            raise
        return default
