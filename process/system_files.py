from pathlib import Path

from loguru import logger

from configuration import read_config
from model import OptimizationParams, PrintParams
from move_commands import (
    close_valve,
    header,
    move_statement,
    move_z_direction,
    open_valve,
    print_statement,
)
from process.params import format_key, parse_parameters
from server import post_data
from util import get_interpolated_value, parse_float


def format_line(params: PrintParams, print_distance: float, pitch: float):
    return [
        *move_z_direction(params.approach_speed, -params.travel_height),
        *open_valve(params.valve_distance, params.open_speed, params.open_delay),
        *print_statement(params.print_speed, x=print_distance),
        *close_valve(params.close_speed, params.close_delay),
        *move_z_direction(params.exit_speed, params.travel_height),
        f"speed {params.travel_speed}",
        move_statement(x=-print_distance, y=pitch),
    ]


def get_optimization_params(parameters):
    ret = {}
    for k, v in parameters.items():
        if type(k) != str:
            continue
        if any(field in k for field in ["pitch_0", "print_distance_0", "step_count_0"]):
            new = format_key(k)
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


def write_script(values: dict):
    settings = read_config()
    post_data("optimization_raw", values)
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
