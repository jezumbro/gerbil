from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import List


@dataclass
class Settings:
    uuid: str
    project_dir: str
    optimization_project: str
    script_dir: str
    eps: float = 0.005
    recipes: List[dict] = None
    slic3r_exe: str = ""
    recipe_dir: str = "recipes"


@dataclass
class OptimizationParams:
    parameters: List[PrintParams]


@dataclass
class PrintParams:
    width: float = 0.144
    approach_speed: float = 5
    exit_speed: float = 5

    travel_speed: float = 30
    travel_height: float = 0.5
    dispense_gap: float = 0.5

    valve_distance: float = 0.2
    open_speed: float = 0.2
    open_delay: float = 0.0

    print_speed: float = 8

    close_speed: float = 0.1
    close_delay: float = 0.0

    @property
    def first_height(self):
        return self.dispense_gap + self.travel_height

    @classmethod
    def parameters(cls):
        return cls.__annotations__.keys()


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
