from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List

from loguru import logger

from model import Settings
from util import first
from validaton.main import good_float

from .configuration import config_path


def process(values: Dict[str, str], settings: dict):
    logger.debug("optimization process")
    logger.debug(values)
    pass


@dataclass
class Recipe:
    name: str
    data: dict

    def save_recipe_to_disk(self, file: RecipeFile):
        existing = file.load()
        existing[self.name] = self.data
        file.save(existing)

    def save_recipe_to_server(self, url, psk):
        pass


class RecipeFile:
    path: Path = Path("./recipes.json")
    data: dict = None

    def load(self):
        if not self.path.is_file():
            self.data = {}
        else:
            with open(self.path, "r") as f:
                self.data = json.load(f)

    def save(self):
        with open(self.path, "w") as f:
            json.dump(self.data, f)

    def add_recipe(self, r: Recipe):
        self.data[r.name] = r

    def __getitem__(self, item):
        return self.data[item]


def save_recipe(values: Dict[str, str], settings: dict, path=None):
    recipe_name = values.get("recipe_name")
    if not recipe_name:
        logger.error("Invalid recipe name")
        return
    good_recipe = get_settings(values)
    if not good_recipe:
        logger.debug(good_recipe)
        logger.error("Invalid argument in settings")
        return
    logger.debug(settings)
    recipes: List[dict] = settings.get("recipes", [])

    def match_name(x: dict):
        return x.get("recipe_name").casefold() == recipe_name.casefold()

    recipe: dict = first(recipes, condition=match_name, default=None)


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
        values[f"{k}_0"] = v


def load_recipe(values: Dict[str, str], settings: dict):
    def match_name(x: dict):
        return values.get("recipe_name").casefold() == x.get("recipe_name").casefold()

    recipe = first(settings.get("recipes"), condition=match_name, default=None)
    set_values(values, recipe)
    return


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
