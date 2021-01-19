from PySimpleGUI import Window

from .configuration import on_load
from .write import process


def process_optimization(values: str, settings: dict, **kwargs):
    return process(values, settings)


def process_load(**kwargs):
    return on_load()
