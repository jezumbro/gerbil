from typing import Dict


def check_input(event: str, values: Dict[str, str], window, **kwargs):
    element = window[event]
    if good_float(event, values):
        element.update(text_color="black")
        return True
    element.update(text_color="red")
    return False


def good_float(e: str, v: Dict[str, str]):
    try:
        d = float(v.get(e))
        return f"{d:0.3f}"
    except ValueError as q:
        return None
