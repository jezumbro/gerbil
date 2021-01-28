from pprint import pprint

from gcode.parse import process_g1
import pytest


@pytest.fixture()
def starting_point():
    return 0, 0, 0


def test_g1_turns_on_printing(params, starting_point):
    printing = False
    line = "G1 X11.337 Y31.079 E0.00326 "
    lines, point, printing = process_g1(line, params, printing, starting_point)
    pprint(lines)
    assert point == [11.337, 31.079, 0]
    assert printing is True
    assert type(lines) == list


def test_g1_keeps_printing(params, starting_point):
    printing = True
    line = "G1 X11.337 Y31.079 E0.00326 "
    lines, point, printing = process_g1(line, params, printing, starting_point)
    pprint(lines)
    assert point == [11.337, 31.079, 0]
    assert printing is True
    assert type(lines) == list
    assert len(lines) == 1


def test_g1_stops_printing(params, starting_point):
    printing = True
    line = "G1 X11.337 Y31.079"
    lines, point, printing = process_g1(line, params, printing, starting_point)
    pprint(lines)
    assert point == [11.337, 31.079, 0]
    assert printing is False
    assert type(lines) == list
    assert len(lines) == 6


def test_weird_g1_command(params, starting_point):
    starting_point = (1, 1, 1)
    printing = True
    line = "G1 X11.337 Y31.079 Z0.5"
    lines, point, printing = process_g1(line, params, printing, starting_point)
    pprint(lines)
    assert point == starting_point
    assert printing is True


def test_random_e(params, starting_point):

    printing = False
    line = "G1 E3.2"
    lines, point, printing = process_g1(line, params, printing, starting_point)
    pprint(lines)
    assert point == starting_point
    assert printing is False
