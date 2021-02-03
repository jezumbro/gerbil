from configuration import config_path, read_config, write_config

from .system_files import write_script
from .write import get_recipe, load_recipe, save_recipe


def process_optimization(values: dict, settings: dict, **kwargs):
    return write_script(values)


def process_startup(**kwargs):
    if config_path.is_file():
        return read_config()
    return write_config()


def process_save(values: dict, settings: dict, **kwargs):
    if name := values.get("recipe_name"):
        data = {**get_recipe(values), "recipe_name": name}
        return save_recipe(data, name)
    return settings


def process_load(values: dict, settings: dict, **kwargs):
    recipe_name = values.get("recipe_name")
    if not recipe_name:
        return
    return load_recipe(values, settings)
