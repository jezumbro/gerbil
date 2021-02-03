import pytest
from pprint import pprint
from line_process.system_files import get_default_printing_params


def test_get_params(app_values):
    q = get_default_printing_params(app_values)
    assert q.line_width == 0.1
