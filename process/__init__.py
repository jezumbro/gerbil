from .configuration import startup
from .system_files import write_script
from .write import get_recipe, load_recipe, process, save_recipe


def process_optimization(values: dict, settings: dict, **kwargs):
    return write_script(values)


def process_startup(**kwargs):
    return startup()


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
