from pathlib import Path
from typing import Dict, List

from loguru import logger

from util import first
from validaton.main import good_float


def process(values: Dict[str, str], settings: dict):
    logger.debug("optimization process")
    logger.debug(values)
    pass


def save_settings(values: Dict[str, str], settings: dict):
    process_name = values.get("process_name")
    if not process_name:
        logger.error("Invalid process name")
        return
    good_values = get_settings(values)
    if not good_values:
        logger.error("Unable to invalid argument in settings")
        return
    recipes: List[dict] = settings["recipes"]

    def match_name(x: dict):
        return x.get("name").casefold() == process_name.casefold()

    recipe = first(recipes, condition=match_name, default=None)
    # TODO
    if not recipe:
        recipes.append()
    pass


def get_settings(values: Dict[str, str]):
    if any(good_float(k, values) is None for k, _ in values.items() if valid_key(k)):
        logger.error("Unable to invalid argument in settings")
        return
    return {k: good_float(k, values) for k, v in values.items() if valid_key(k)}


def valid_key(x: str):
    return x.endswith("_0") or x.endswith("_1")


def convert_key(x: str):
    if x.endswith("_0"):
        return x.replace("_0", "")
    return None
