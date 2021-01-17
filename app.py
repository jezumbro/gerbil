import PySimpleGUI as sg
from loguru import logger

from design.parameters import parameter_tab
from design.process import process_tab
from process import optimization_process
from validaton.main import check_input

t = [[sg.TabGroup([[parameter_tab(), process_tab()]])]]
window = sg.Window("Window Title", t)
lookup = {"check_input": check_input, "optimization": optimization_process}

# Display and interact with the Window using an Event Loop
logger.info("starting gerbil")
while True:
    event, values = window.read()

    if event == sg.WINDOW_CLOSED:
        break
    key: str = event
    if key.endswith("_0") or key.endswith("_1"):
        key = "check_input"
    if func := lookup.get(key):
        func(event=event, values=values, window=window)
# Finish up by removing from the screen
window.close()
