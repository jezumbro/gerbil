import json
from pathlib import Path
from uuid import uuid4

from loguru import logger

from model import Settings

config_path = Path("./settings.json")


def read_config(p: Path = config_path):
    try:
        with open(p.absolute(), "r") as f:
            return Settings(**json.load(f))
    except Exception as e:
        logger.error(f"Issue reading settings.json, {e}")
        return Settings(**default_config)


default_config = {
    "uuid": str(uuid4()),
    "eps": 0.005,
    "project_dir": r"C:\Transfer\Installs\MTGen3\Projects",
    "optimization_project": "optimization",
    "script_dir": "scripts",
    "recipes": [],
}


def write_config(p: Path = config_path, data: dict = None):
    data = data or default_config
    with open(p.absolute(), "w") as f:
        json.dump(data, f)
    return Settings(**data)


def format_key(k: str):
    return k.replace("settings_", "")


def save_config(values, path=config_path, **kwargs):
    settings = read_config(path)
    ret = {
        format_key(k): v
        for k, v in values.items()
        if type(k) == str and k.startswith("settings_")
    }
    data = {**settings.__dict__, **ret}
    write_config(path, data=data)


if __name__ == "__main__":
    write_config()
