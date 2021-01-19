import json
from pathlib import Path


def read_config(p: Path):
    with open(p.absolute(), "r") as f:
        return json.load(f)


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
    return data


def on_load():
    settings = Path("./settings.json")
    if settings.is_file():
        return read_config(settings)
    return write_config(settings)


if __name__ == "__main__":
    on_load()
