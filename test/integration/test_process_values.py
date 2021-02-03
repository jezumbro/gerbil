from pprint import pprint

import pytest

from process.params import get_printing_params


def test_get_params(app_values):
    q = get_printing_params(app_values)
    assert q.width == 0.1
