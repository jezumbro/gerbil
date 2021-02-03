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
        0: (None, None),
        1: "Parameters",
        "Browse": "",
        "Browse0": "",
        "design_file": "",
        "humidity": "",
        "line_approach_speed_0": "2",
        "line_approach_speed_1": "",
        "line_close_delay_0": "0",
        "line_close_delay_1": "",
        "line_close_speed_0": "0.1",
        "line_close_speed_1": "",
        "line_dispense_gap_0": "0.500",
        "line_dispense_gap_1": "0",
        "line_exit_speed_0": "15",
        "line_exit_speed_1": "",
        "line_width_0": "0.100",
        "line_open_delay_0": "0",
        "line_open_delay_1": "",
        "line_open_speed_0": "0.1",
        "line_open_speed_1": "",
        "line_pitch_0": "0.500",
        "line_pressure_0": "0",
        "line_pressure_1": "",
        "line_print_distance_0": "10",
        "line_print_speed_0": "1",
        "line_print_speed_1": "",
        "line_step_count_0": "10",
        "line_travel_height_0": "0.500",
        "line_travel_speed_0": "15",
        "line_travel_speed_1": "",
        "line_valve_distance_0": "0",
        "line_valve_distance_1": "",
        "line_wait_time_0": "0",
        "line_wait_time_1": "",
        "load": "",
        "material": "",
        "pen_tip": "",
        "recipe_name": "",
        "save": "",
        "settings_slic3r_exe": "/home/zekezumbro/Downloads/prusa3d_linux_2_3_0/PrusaSlicer-2.3.0+linux-x64-202101111322.AppImage",
        "temperature": "",
    }


@pytest.fixture
def bad_values(app_values):
    return {**app_values, "line_width_0": "1q"}
