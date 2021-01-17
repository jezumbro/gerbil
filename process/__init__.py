from PySimpleGUI import Window

from .optimization import process


def optimization_process(values: str, **kwargs):
    return process(values)
