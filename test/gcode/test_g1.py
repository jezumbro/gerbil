from pprint import pprint

from gcode.parse import process_g1
import pytest

from model import PrintParams


@pytest.mark.parametrize(
    "line,expected",
    [
        ("G1 X10", "G1 X10"),
        ("G1 Z0.1", "G1 Z0.001 F900.000\n"),
        ("G1 Z0.5", "G1 Z0.401 F900.000\n"),
        ("; hello", "; hello"),
    ],
)
def test_process_g1(line, expected):
    params = PrintParams()
    params.line_width = 0.1
    g1 = process_g1(line, params=params)
    assert g1 == expected
