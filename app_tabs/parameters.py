from typing import List

import PySimpleGUI as sg

from process.configuration import get_recipes
from settings import config


def get_frames():
    layout = [
        [("Height", height_group), ("Optimization", optimization)],
        [("Speed", speed_group), ("Valve", valve_group)],
        [("Pressure", pressure_group), ("Export", export)],
    ]
    ret = []
    for row in layout:
        ret.append(
            [sg.Frame(title=title, layout=func(), size=(40, 40)) for title, func in row]
        )
    return ret


default_size = (15, 1)
unit_size = (10, 1)


def tunable_parameter(title, name, unit="mm", default=None):
    if not title:
        return [sg.T()]
    return [
        sg.T(text=title, key=f"{name}_label", size=default_size),
        sg.I(default, key=f"{name}_0", size=default_size, enable_events=True),
        sg.T(text=unit, key=f"{name}_unit", size=unit_size),
        sg.I(None, key=f"{name}_1", size=default_size),
    ]


def fixed_parameter(title, name, unit="mm", default=None, append_blank=True):
    elements = [
        sg.T(text=title, key=f"{name}_label", size=default_size),
        sg.I(default, key=f"{name}_0", size=default_size, enable_events=True),
        sg.T(text=unit, key=f"{name}_unit", size=unit_size),
    ]
    if append_blank:
        elements.append(sg.T(size=default_size))
    return elements


def blank_parameter_row():
    return tuple([""] * 4)


def valve_group():
    rows = [
        ("Distance:", "valve_distance", "mm", "0"),
        ("Open Speed:", "open_speed", "mm/s", "0.1"),
        ("Open Delay:", "open_delay", "sec", "0"),
        ("Close Speed:", "close_speed", "mm/s", "0.1"),
        ("Close Delay:", "close_delay", "sec", "0"),
    ]
    return [tunable_parameter(*row) for row in rows]


def pressure_group():
    return [
        tunable_parameter("Pressure:", "pressure", "psi", "0"),
        tunable_parameter("Wait Time:", "wait_time", "sec", "0"),
        [
            sg.T(text="Temperature:", size=default_size),
            sg.I(None, key=f"temperature", size=default_size, enable_events=True),
            sg.T(text="C", size=unit_size),
            sg.T(size=default_size),
        ],
        [
            sg.T(text="Humidity:", size=default_size),
            sg.I(None, key=f"humidity", size=default_size, enable_events=True),
            sg.T(text="%", size=unit_size),
            sg.T(size=default_size),
        ],
    ]


def speed_group():
    rows = [
        ("Travel Speed:", "travel_speed", "mm/s", "15"),
        ("Approach Speed:", "approach_speed", "mm/s", "2"),
        ("Print Speed:", "print_speed", "mm/s", "1"),
        ("Exit Speed:", "exit_speed", "mm/s", "15"),
        blank_parameter_row(),
    ]
    return [tunable_parameter(*row) for row in rows]


def height_group():
    return [
        fixed_parameter("Line Width:", "line_width", "mm", "0.100"),
        tunable_parameter("Travel Height:", "travel_height", "mm", "0.500"),
        tunable_parameter("Dispense Gap:", "dispense_gap", "mm", "0.500"),
    ]


def optimization():
    rows = [
        ("Print Distance (x):", "print_distance", "mm", "10"),
        ("Pitch (y):", "pitch", "mm", "0.500"),
        ("Steps:", "step_count", "mm", "10"),
    ]
    return [fixed_parameter(*row) for row in rows]


def export():
    return [
        [
            sg.T("Recipe Name:", size=default_size),
            sg.InputCombo(values=get_recipes(), key="recipe_name", size=default_size),
        ],
        [sg.T("Material:", size=default_size), sg.I(key="material", size=default_size)],
        [sg.T("Pen Tip:", size=default_size), sg.I(key="pen_tip", size=default_size)],
        [
            sg.Button("Load", key="load", size=(12, 1)),
            sg.Button("Save", key="save", size=(12, 1)),
            sg.T(size=(9, 1)),
            sg.Button("Export", key="optimization", size=(12, 1)),
        ],
    ]


def parameter_tab():
    return sg.Tab(title="Parameters", layout=get_frames())
