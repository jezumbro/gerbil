from __future__ import annotations

from dataclasses import dataclass
from typing import List


@dataclass
class Settings:
    uuid: str
    project_dir: str
    optimization_project: str
    script_dir: str
    eps: float = 0.005
    recipes: List[dict] = None


@dataclass
class OptimizationParams:
    parameters: List[PrintParams]


@dataclass
class PrintParams:
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
