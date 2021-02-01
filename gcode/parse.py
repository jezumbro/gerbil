from datetime import datetime
from pathlib import Path
from typing import List, Tuple

from loguru import logger
from pygcode import GCodeFeedRate, GCodeLinearMove, Line

from model import PrintParams
from move_commands import close_valve, move_z_direction, open_valve
from util import first


def find_linear_move(x):
    return isinstance(x, GCodeLinearMove) and "Z" in x.params.keys()


def find_feed_rate(x):
    return isinstance(x, GCodeFeedRate)


def process_g1(line: str, params: PrintParams):
    if "Z" in line:
        x = Line(line)
        g1: GCodeLinearMove = first(x.gcodes, condition=find_linear_move)
        fr: GCodeFeedRate = first(x.gcodes, condition=find_feed_rate, default=None)
        z_value = g1.params["Z"].value - params.line_width + 0.001
        f_value = fr.word.value if fr and fr.word else 900
        return f"G1 Z{z_value:.3f} F{f_value:.3f}\n"
    return line


def process_gcode(line: str, params: PrintParams):
    if line.startswith("G1"):
        return process_g1(line, params)
    return line


def get_output_file(file: Path):
    o = str(file.absolute())
    return Path(o.split(".")[0] + "_mod.gcode")


def get_input_file(file: Path):
    o = str(file.absolute())
    return Path(o.split(".")[0] + ".gcode")


def write_psj_file(params: PrintParams, file: Path):
    output = get_output_file(file)
    file = get_input_file(file)
    with open(output, "w") as ofp:
        with open(file, "r") as fp:
            for line in fp.read().splitlines(keepends=True):
                ofp.write(process_gcode(line, params))
    logger.info(f"created psj file: {output}")
