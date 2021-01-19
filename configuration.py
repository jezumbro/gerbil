import json
from pathlib import Path
from uuid import uuid4

from model import Settings

config_path = Path("./settings.json")


def read_config(p: Path = config_path):
    with open(p.absolute(), "r") as f:
        return Settings(**json.load(f))


def write_config(p: Path = config_path):
    data = {
        "uuid": str(uuid4()),
        "eps": 0.005,
        "project_dir": r"C:\Transfer\Installs\MTGen3\Projects",
        "optimization_project": "optimization",
        "script_dir": "scripts",
        "recipes": [],
    }
    with open(p.absolute(), "w") as f:
        json.dump(data, f)
    return Settings(**data)
