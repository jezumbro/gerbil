from pathlib import Path
from typing import Dict, List

from loguru import logger

from util import first
from validaton.main import good_float


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
