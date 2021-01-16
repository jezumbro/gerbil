from pathlib import Path

from gerber import read as gerber_read
from gerber.rs274x import GerberFile
from shapely.geometry import CAP_STYLE, JOIN_STYLE, MultiPolygon, Polygon

from rs274.primitives import lookup
from settings import config
from stl.process_stl import extrude_many_polygons


def plot(polygons: MultiPolygon):
    from matplotlib import pyplot as plt

    if isinstance(polygons, MultiPolygon):
        for polygon in polygons:
            plt.plot(*polygon.exterior.xy)
    plt.show()


def create_polygons(file_name: str = None):
    p = Path(file_name)
    layer: GerberFile = gerber_read(p.absolute())
    missing = set()
    dark = Polygon()
    for idx, primitive in enumerate(layer.primitives):
        key = type(primitive), primitive.level_polarity
        if func := lookup.get(key):
            dark = dark.union(func(primitive))
            continue
        missing.add(key)
    return merge_close_polygons(dark)


def merge_close_polygons(shape, eps: float = config.eps):
    return shape.buffer(
        distance=eps, cap_style=CAP_STYLE.square, join_style=JOIN_STYLE.mitre
    ).buffer(distance=-eps, cap_style=CAP_STYLE.square, join_style=JOIN_STYLE.mitre)


if __name__ == "__main__":
    q = create_polygons(config.design_file)
    # plot(q)
    triangles = extrude_many_polygons(q, 5)
    from stl.write_stl import write_stl

    write_stl(triangles, "test.stl")
