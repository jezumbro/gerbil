import json
from pathlib import Path

from process.model import Settings

config_path = Path("./settings.json")


def read_config(p: Path):
    with open(p.absolute(), "r") as f:
        return Settings(**json.load(f))


def write_config(p: Path):
    data = {
        "eps": 0.005,
        "project_dir": r"C:\Transfer\Installs\MTGen3\Projects",
        "optimization_project": "optimization",
        "script_dir": "scripts",
        "recipes": [],
    }
    with open(p.absolute(), "w") as f:
        json.dump(data, f)
    return Settings(**data)


def get_recipes():
    pass


def startup():
    if config_path.is_file():
        return read_config(config_path)
    return write_config(config_path)


if __name__ == "__main__":
    startup()
