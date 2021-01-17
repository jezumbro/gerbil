from typing import List, Tuple

from gerber.primitives import Circle, Line, Rectangle, Region
from shapely.geometry import Point, Polygon


def process_rectangle(x: Rectangle):
    return Polygon(x.vertices)


def process_circle(x: Circle):
    return Point(x.position).buffer(x.radius)


def process_line(x: Line) -> List[Tuple[float, float]]:
    return [x.start, x.end]


def get_verticies(x: Region):
    ret = []
    for primitive in x.primitives:
        key = type(primitive)
        if func := lookup.get(key):
            for i in func(primitive):
                ret.append(i)
    return ret


def find_holes(coords: List[Tuple[float, float]]):
    holes = []
    print("total", len(coords))
    for idx, coord in enumerate(coords, start=1):
        reduced_list = coords[idx:]
        if coord in reduced_list[1:]:
            print(coord, idx - 1, reduced_list[1:].index(coord))
    pass


def fix_region(v):
    holes = find_holes(v)
    return Polygon(v)


def process_region(x: Region):
    return fix_region(get_verticies(x))


lookup = {
    (Rectangle, "dark"): process_rectangle,
    (Circle, "dark"): process_circle,
    (Region, "dark"): process_region,
    Line: process_line,
}
