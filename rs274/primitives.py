from typing import List, Tuple

from gerber.primitives import Circle, Line, Rectangle, Region
from shapely.geometry import Point, Polygon


def process_rectangle(x: Rectangle):
    return Polygon(x.vertices)


def process_circle(x: Circle):
    return Point(x.position).buffer(x.radius)


def process_line(x: Line) -> List[Tuple[float, float]]:
    return [x.start, x.end]


def process_region(x: Region):
    vertices = []
    for primitive in x.primitives:
        key = type(primitive)
        if func := lookup.get(key):
            for i in func(primitive):
                if i in vertices:
                    continue
                vertices.append(i)
    return Polygon(vertices)


lookup = {
    (Rectangle, "dark"): process_rectangle,
    (Circle, "dark"): process_circle,
    (Region, "dark"): process_region,
    Line: process_line,
}
