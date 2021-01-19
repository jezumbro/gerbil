from collections import defaultdict
from datetime import datetime
from pathlib import Path

from loguru import logger

from process.model import OptimizationParams, PrintParams
from process.write import load_settings
from util import get_interpolated_value
from validaton.main import parse_float


def move_statement(*, x: float = 0, y: float = 0, z: float = 0):
    return f"move {x:.3f} {y:.3f} {z:.3f}"


def move_z_direction(speed: float, distance: float):
    return [f"speed {speed:.3f}", move_statement(z=distance)]


def print_statement(print_speed: float, *, x: float = 0, y: float = 0):
    return [f"speed {print_speed:.3f}", move_statement(x=x, y=y)]


def open_valve(distance: float, speed: float, delay: float):
    return [f"valverel {distance:.3f} {speed:.3f}", f"wait {delay:.3f}"]


def close_valve(speed: float, delay: float):
    return [f"valverel 0.000 {speed:.3f}", f"wait {delay:.3f}"]


def format_line(params: PrintParams, print_distance: float, pitch: float):
    return [
        *move_z_direction(params.approach_speed, -params.travel_height),
        *open_valve(params.valve_distance, params.open_speed, params.open_delay),
        *print_statement(params.print_speed, x=print_distance),
        *close_valve(params.close_speed, params.close_delay),
        *move_z_direction(params.exit_speed, params.travel_height),
        move_statement(x=-print_distance, y=pitch),
    ]


def parse_parameters(parameters):
    ret = defaultdict(list)
    for k, v in parameters.items():
        if type(k) is not str:
            continue
        new = k.replace("_0", "").replace("_1", "")
        if new not in PrintParams.parameters():
            continue
        ret[new].append(parse_float(v))
    for k, v in ret.items():
        if len(v) == 1:
            v.append(None)
    return ret


def get_optimization_params(parameters):
    ret = {}
    for k, v in parameters.items():
        if k in ["pitch_0", "print_distance_0", "step_count_0"]:
            new = k.replace("_0", "").replace("_1", "")
            ret[new] = parse_float(v)
    return ret


def get_optimization_parameters(parameters: dict):
    printing_params = parse_parameters(parameters)
    optimization_params = get_optimization_params(parameters)
    steps = int(optimization_params["step_count"])
    op = OptimizationParams(parameters=[])
    for step in range(steps):
        op.parameters.append(
            PrintParams(
                **{
                    k: get_interpolated_value(start, step, end, steps)
                    for k, (start, end) in printing_params.items()
                }
            )
        )

    return op, optimization_params


def format_optimization_job_lines(parameters: dict):
    op, optimization_params = get_optimization_parameters(parameters)
    print_distance = optimization_params["print_distance"]
    pitch = optimization_params["pitch"]
    previous_params = op.parameters[0]
    lines = header(previous_params)
    for params in op.parameters:
        if params.dispense_gap != previous_params.dispense_gap:
            lines.append(
                move_statement(z=params.dispense_gap - previous_params.dispense_gap)
            )
        lines.extend(format_line(params, print_distance, pitch))
        previous_params = params
    return lines


def header(params: PrintParams):
    return [
        f"// optimization script generated by gerbil",
        f"// {datetime.now()}",
        f"speed {params.travel_speed:.3f}",
        move_statement(
            z=params.first_height,
        ),
    ]


def write_script(values: dict):
    settings = load_settings()
    psj_file = (
        Path(settings.project_dir)
        / settings.optimization_project
        / settings.script_dir
        / "optimization_script.txt"
    )
    psj_dir = (
        Path(settings.project_dir) / settings.optimization_project / settings.script_dir
    )
    psj_dir.absolute().mkdir(parents=True, exist_ok=True)
    with open(psj_file.absolute(), "w") as f:
        f.write("\n".join(format_optimization_job_lines(values)))
    logger.info(f"Exported optimization file {psj_file.absolute()}")