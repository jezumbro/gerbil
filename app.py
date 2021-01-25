import PySimpleGUI as sg
from loguru import logger

from app_tabs import parameter_tab, process_tab, settings_tab
from configuration import save_config
from line_process import (
    process_load,
    process_optimization,
    process_save,
    process_startup,
)
from slic3r import process_slicer
from validaton.main import check_input

t = [[sg.TabGroup([[parameter_tab(), process_tab(), settings_tab()]])]]
window = sg.Window("Gerbil", t)
lookup = {
    "check_input": check_input,
    "settings_save_config": save_config,
    "optimization": process_optimization,
    "process_file": process_slicer,
    "save": process_save,
    "load": process_load,
}


# Display and interact with the Window using an Event Loop
settings = process_startup()
while True:
    event, values = window.read()

    if event == sg.WINDOW_CLOSED:
        break
    key: str = event
    if key.endswith("_0") or key.endswith("_1"):
        key = "check_input"
    if func := lookup.get(key):
        func(event=event, values=values, window=window, settings=settings)


# Finish up by removing from the screen
window.close()
