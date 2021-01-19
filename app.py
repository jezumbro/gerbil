import queue
from logging import getLogger
from logging.handlers import QueueHandler

import PySimpleGUI as sg
from loguru import logger

from app_tabs.logging import log_tab
from app_tabs.parameters import parameter_tab
from app_tabs.process import process_tab
from process import (process_load, process_optimization, process_save,
                     process_startup)
from validaton.main import check_input

t = [[sg.TabGroup([[parameter_tab(), process_tab(), log_tab()]])]]
window = sg.Window("Gerbil", t)
lookup = {
    "check_input": check_input,
    "optimization": process_optimization,
    "save": process_save,
    "load": process_load,
}

log_queue = queue.Queue()
queue_handler = QueueHandler(log_queue)
# logger = getLogger()

logger.add(queue_handler)

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

    try:
        record = log_queue.get(block=False)
    except queue.Empty:
        pass
    else:
        msg = queue_handler.format(record)
        window["-LOG-"].update(msg + "\n", append=True)
# Finish up by removing from the screen
window.close()
