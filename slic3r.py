import os
from pathlib import Path

from loguru import logger

from configuration import read_config
from gcode.parse import write_psj_file
from model import PrintParams
from process.params import get_printing_params
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
    params = get_printing_params(values=values)
    design_file = values.get("design_file")
    if not design_file:
        logger.warning("Unable to find design file")
    file = Path(design_file)
    call_slic3r(params, file)
    write_psj_file(params, file)


def call_slic3r(params: PrintParams, file_path: Path):
    if not str(file_path.absolute()).endswith(".stl"):
        file_path = update_file_path_to_stl(file_path, params.width)
    cmd = extract_slicer_command(file_path, params)
    logger.info(f"slic3r status: {not os.system(cmd)}")
    logger.info(f"output file: {file_path.absolute()}")


def update_file_path_to_stl(file_path: Path, line_width: float):
    stl_file = get_stl_file_path(file_path)
    triangles = extrude_many_polygons(
        create_polygons(str(file_path.absolute())), line_width
    )
    write_ascii_stl(triangles, str(stl_file.absolute()))
    file_path = stl_file
    return file_path


def extract_slicer_command(file_path: Path, params: PrintParams):
    settings = read_config()
    slicer = Path(settings.slic3r_exe)
    cmd = (
        f"{slicer.absolute()} --export-gcode --dont-arrange "
        f"--nozzle-diameter {params.width} "
        f"--first-layer-height {params.width} "
        f"--layer-height {params.width} "
        f"--filament-retract-lift {params.travel_height} "
        f"--retract-speed {params.approach_speed} "
        f"--travel-speed {params.travel_speed} "
        "--infill-only-where-needed --infill-overlap 30% "
        f"--first-layer-extrusion-width {params.width} "
        "--perimeters 2 "
        f"--external-perimeter-extrusion-width {params.width + .001} "
        f"--external-perimeter-extrusion-width {params.width + .001} "
        f"--perimeter-extrusion-width {params.width + .001} "
        f"--infill-extrusion-width {params.width + .001} "
        f"--first-layer-speed {params.print_speed:.3f} "
        f"--infill-first --infill-only-where-needed --skirts 0 "
        " "
        f"{file_path.absolute()}"
    )
    return cmd


if __name__ == "__main__":
    file = Path(config.design_file)
    params = PrintParams()
    params.width = 0.08
    call_slic3r(params, file)
    write_psj_file(params, file)
