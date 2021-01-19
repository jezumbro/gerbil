import PySimpleGUI as sg

from design.parameters import parameter_tab
from design.process import process_tab
from process import process_load, process_optimization
from validaton.main import check_input

t = [[sg.TabGroup([[parameter_tab(), process_tab()]])]]
window = sg.Window("Window Title", t)
lookup = {"check_input": check_input, "optimization": process_optimization}

# Display and interact with the Window using an Event Loop
settings = process_load()
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
