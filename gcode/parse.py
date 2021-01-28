from pathlib import Path
from typing import List, Tuple
from model import PrintParams
from move_commands import (
    close_valve,
    open_valve,
    move_statement,
    move_z_direction,
)


def process_g1_coords(line: str):
    p = False
    coord = [0, 0, 0]
    for l in line.split(" ")[1:]:
        if "X" in l.upper():
            coord[0] = float(l.replace("X", ""))
        if "Y" in l.upper():
            coord[1] = float(l.replace("Y", ""))
        if "Z" in l.upper():
            coord[2] = float(l.replace("Z", ""))
        if "E" in l.upper():
            p = True
    return coord, p


def calculate_delta(previous, new):
    return {
        "x": new[0] - previous[0],
        "y": new[1] - previous[1],
        "z": new[2] - previous[2],
    }


def process_g1(
    line: str, params: PrintParams, printing: bool, previous: Tuple[float, float, float]
):
    new, status = process_g1_coords(line)
    if new[-1] != 0 or new == [0, 0, 0]:
        return [], previous, printing
    move = move_statement(**calculate_delta(previous, new))
    if printing != status:
        if printing:
            return (
                [
                    *close_valve(params.close_speed, params.close_delay),
                    *move_z_direction(params.exit_speed, params.travel_height),
                    f"speed {params.travel_speed}",
                    move,
                ],
                new,
                False,
            )
        return (
            [
                *move_z_direction(params.approach_speed, -params.travel_height),
                f"speed {params.print_speed}",
                *open_valve(
                    params.valve_distance, params.open_speed, params.open_delay
                ),
                move,
            ],
            new,
            True,
        )
    return [move], new, printing


def process_file(params: PrintParams, lines: List[str]):
    previous = (0, 0, 0)
    printing = False
    out_lines = move_z_direction(params.exit_speed, params.travel_height)
    for line in lines:
        key = line.split(" ")[0].upper()
        if func := lookup.get(key):
            o, new, printing = func(line, params, printing, previous)
            previous = new
            out_lines.extend(o)
    pprint(out_lines)
    pass


lookup = {"G1": process_g1}

if __name__ == "__main__":
    from settings import config
    from pprint import pprint

    q = config.design_file.replace(".gbr", ".gcode")
    file = Path(q)
    with open(file, "r") as fp:
        data = fp.readlines()
    process_file(params=PrintParams(), lines=data)
