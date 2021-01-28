import pytest
from shapely.geometry import Polygon

from model import PrintParams

simple_rect = Polygon([(0, 0), (0, 50), (50, 50), (50, 0)])
simple_triangle = Polygon([(0, 0), (0, 50), (50, 0)])


@pytest.fixture
def params():
    return PrintParams()


@pytest.fixture
def app_values():
    return {
        "line_width_0": "0.100",
        "travel_height_0": "0.500",
        "dispense_gap_0": "0.009",
        "dispense_gap_1": "0",
        "print_distance_0": "10",
        "pitch_0": "0.500",
        "step_count_0": "10",
        "travel_speed_0": "15",
        "travel_speed_1": "",
        "approach_speed_0": "2",
        "approach_speed_1": "4",
        "print_speed_0": "1",
        "print_speed_1": "",
        "exit_speed_0": "15",
        "exit_speed_1": "",
        "valve_distance_0": "0",
        "valve_distance_1": "",
        "open_speed_0": "0.1",
        "open_speed_1": "",
        "open_delay_0": "0",
        "open_delay_1": "",
        "close_speed_0": "0.1",
        "close_speed_1": "",
        "close_delay_0": "0",
        "close_delay_1": "",
        "pressure_0": "0",
        "pressure_1": "",
        "wait_time_0": "0",
        "wait_time_1": "",
        "temperature": "",
        "humidity": "",
        "material": "",
        "pen_tip": "",
        "-LOG-": "\n",
        0: "Parameters",
    }
