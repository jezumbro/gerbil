from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Dict, List

from loguru import logger

from configuration import config_path
from model import PrintParams, Settings
from util import first
from validaton.main import good_float


def save_recipe(params: PrintParams, path: Path):
    with open(path.absolute(), "w") as f:
        json.dump(params, f)

    logger.info(f"wrote recipe at {path.absolute()}")


def load_settings(path=None):
    with open((path or config_path).absolute(), "r") as f:
        return Settings(**json.load(f))


def save_settings(settings: dict, path=None):
    with open((path or config_path).absolute(), "w") as f:
        json.dump(settings, f)


def get_recipe(values: dict):
    return {convert_key(k): v for k, v in values.items() if convert_key(k)}


def get_settings(values: Dict[str, str]):
    try:
        return {
            k: good_float(k, values) for k, v in values.items() if valid_key(k) and v
        }
    except:
        return None


def set_values(values, recipe):
    for k, v in recipe.items():
        values[f"line_{k}_0"] = str(v)
    return values


def load_all_files():
    p = Path("recipes")
    logger.info(p.absolute())
    for f in p.rglob("*.json"):
        yield f


def load_recipe(name: str, values: Dict[str, str]):
    if not name.endswith(".json"):
        name += ".json"

    def match_name(x: Path):
        i_str = str(x.absolute())
        print(i_str)
        return i_str.casefold().endswith(name.casefold())

    files = list(load_all_files())
    recipe = first(files, condition=match_name, default=None)
    if not recipe:
        logger.info(list(load_all_files()))
        logger.warning(f"unable to find recipe {name}")
        return
    logger.info(f"loading recipe {recipe}")
    with open(recipe, "r") as fp:
        data = json.load(fp)
    return set_values(values, data)


def valid_key(x: str):
    if type(x) is not str:
        return False
    return x.endswith("_0") or x.endswith("_1")


def convert_key(x: str):
    if type(x) is not str:
        return None
    if x.endswith("_0"):
        return x.replace("_0", "")
    return None


if __name__ == "__main__":
    load_recipe("test.json", values={})
