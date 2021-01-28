import os
from pathlib import Path

from loguru import logger

from configuration import read_config
from line_process.system_files import get_default_printing_params
from model import PrintParams
from rs274.process_gerber import create_polygons
from settings import config
from stl.process_stl import extrude_many_polygons
from stl.write_stl import write_ascii_stl


def get_stl_file_path(file_path: Path) -> Path:
    p = file_path.absolute()
    file_dir = p.parent
    file_name = p.name.split(".")[0] + ".stl"
    return Path(file_dir) / file_name


def process_slicer(values: dict, **kwargs):
    params = get_default_printing_params(parameters=values)
    design_file = values.get("design_file")
    if not design_file:
        logger.warning("Unable to find design file")
    call_slic3r(params, Path(design_file))


def call_slic3r(params: PrintParams, file_path: Path):
    settings = read_config()
    if not str(file_path.absolute()).endswith(".stl"):
        stl_file = get_stl_file_path(file_path)
        triangles = extrude_many_polygons(
            create_polygons(str(file_path.absolute())), params.line_width
        )
        write_ascii_stl(triangles, str(stl_file.absolute()))
        file_path = stl_file
    cmd = (
        f"{settings.slic3r_exe} --export-gcode --dont-arrange --load config.ini "
        f"--nozzle-diameter {params.line_width} "
        f"--first-layer-height {params.line_width} "
        f"--layer-height {params.line_width} "
        f"--filament-retract-lift {params.travel_height} "
        f"--infill-first --infill-only-where-needed --skirts 0 "
        " "
        f"{file_path.absolute()}"
    )
    logger.info(f"slic3r status: {not os.system(cmd)}")
    logger.info(f"output file: {file_path.absolute()}")


if __name__ == "__main__":
    call_slic3r(PrintParams(), Path(config.design_file))
