from typing import Dict

import PySimpleGUI as sg
from loguru import logger


def check_input(event: str, values: Dict[str, str], window: sg.Window):
    element = window[event]
    if good_input(event, values):
        element.update(text_color="black")
        return
    element.update(text_color="red")


def good_input(e: str, v: Dict[str, str]):
    try:
        d = float(v.get(e))
        return f"{d:0.3f}"
    except ValueError as q:
        return None