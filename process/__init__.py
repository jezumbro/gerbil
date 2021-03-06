from pathlib import Path

from loguru import logger

from configuration import config_path, read_config, write_config
from process.params import get_printing_params

from .recipes import get_recipe, load_recipe, save_recipe
from .system_files import write_script


def process_optimization(values: dict, settings: dict, **kwargs):
    return write_script(values)


def process_startup(**kwargs):
    if config_path.is_file():
        return read_config()
    return write_config()


def process_save(values: dict, settings: dict, **kwargs):
    name: str = values.get("recipe_name")
    if not name:
        logger.info("invalid recipe name")
        return
    if not name.endswith(".json"):
        name += ".json"

    recipe_folder = Path("./recipes")
    if not recipe_folder.exists():
        recipe_folder.mkdir()
    params = get_printing_params(values)
    if not params:
        logger.info("could not read params")
        return

    recipe = recipe_folder / name
    save_recipe(params.__dict__, path=recipe)


def process_load(values: dict, window, **kwargs):
    recipe_name = values.get("recipe_name")
    if not recipe_name:
        return
    loaded_values = load_recipe(recipe_name, values)
    for k, v in loaded_values.items():
        if type(k) == str and k.startswith("line_"):
            window[k].update(v)
