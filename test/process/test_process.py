from pathlib import Path
from pprint import pprint
from tempfile import TemporaryDirectory

import pytest

from process import save_recipe
from process.system_files import get_optimization_parameters
from util import get_interpolated_value, interpolate


@pytest.mark.skip
def test_save_process():
    with TemporaryDirectory() as d:
        file = Path(d) / "settings.json"
        settings = {}
        save_recipe({"recipe_name": "test", "line_width_0": "0.1"}, settings, path=file)
        pprint(settings)
        assert file.is_file()
        assert settings["recipes"]


def test_interpolation():
    start, end = 0, 1
    steps = 10
    q = list(interpolate(start, end, steps))
    assert len(q) == steps
    assert q[0] == start and q[-1] == end


def test_negative_interpolate():
    start, end = 1, 0
    steps = 10
    q = list(interpolate(start, end, steps))
    assert len(q) == steps
    assert q[0] == start and q[-1] == end


@pytest.mark.skip
def test_single_step():
    start, end = 1, 0
    steps = 1
    q = list(interpolate(start, end, steps))
    assert len(q) == steps
    assert q[0] == start and q[-1] == end


def test_double_step():
    start, end = 1, 0
    steps = 2
    q = list(interpolate(start, end, steps))
    pprint(q)
    assert len(q) == steps
    assert q[0] == start and q[-1] == end


def test_get_value():
    start, end = 1, 0
    steps = 2
    q = get_interpolated_value(start, end=end, steps=steps, step=1)
    assert q == end


def test_get_optimization_parameters(app_values):
    r, o = get_optimization_parameters(app_values)
    assert len(r.parameters) == 10
