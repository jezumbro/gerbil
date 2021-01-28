from itertools import permutations
from math import cos, sin
from typing import List, Tuple

from gerber.primitives import Arc, Circle, Line, Rectangle, Region
from shapely.geometry import Point, Polygon

from util import interpolate, n_wise


def process_rectangle(x: Rectangle):
    return Polygon(x.vertices)


def process_circle(x: Circle):
    return Point(x.position).buffer(x.radius)


def process_line(x: Line) -> List[Tuple[float, float]]:
    return [x.start, x.end]


def get_verticies(x: Region):
    ret = []
    for idx, primitive in enumerate(x.primitives, start=1):
        key = type(primitive)
        if func := lookup.get(key):
            q = list(func(primitive))
            if idx == len(x.primitives):
                ret.extend(q)
            else:
                ret.append(q[0])
            continue
    return ret


def find_holes(coords: List[Tuple[float, float]]):
    return inner_polygons(coords)


def fix_region(v):
    holes = find_holes(v)
    return Polygon(v)


def process_region(x: Region):
    return fix_region(get_verticies(x))


def process_arc(a: Arc):
    x, y = a.center
    if a.direction == "counterclockwise" and a.start_angle == a.end_angle:
        steps = interpolate(a.end_angle, -a.start_angle, 20)
        for step in steps:
            dx, dy = cos(step), sin(step)
            dx *= a.radius
            dy *= a.radius
            yield round(x + dx, 4), round(y + dy, 4)


lookup = {
    (Rectangle, "dark"): process_rectangle,
    (Circle, "dark"): process_circle,
    (Region, "dark"): process_region,
    Line: process_line,
    Arc: process_arc,
}


def inner_polygons(shape):
    shape = shape[1:]
    seen = []
    shapes = set()
    for current_index, point in enumerate(shape):
        if point not in seen:
            seen.append(point)
        else:
            idx = shape.index(point)
            raw = shape[idx : current_index + 1]
            trimmed = trim_shape(raw)
            de_duped = remove_duplicate_points(trimmed)
            shapes.add(de_duped)

    for shape1, shape2 in list(permutations(shapes, 2)):
        if index := find(shape1, shape2):
            new_shape = shape2[:index] + shape2[index + len(shape1) :]
            shapes.add(tuple(remove_duplicate_points(new_shape)))
            shapes.remove(shape2)
    return tuple(shapes)


def trim_shape(shape):
    if len(shape) <= 4:
        return shape
    if shape[0] == shape[-1] and shape[1] == shape[-2]:
        return tuple(shape[1:-1])
    return tuple(shape)


def find(search_for, search_in):
    if len(search_for) > len(search_in):
        return None

    item_count = len(search_for)
    for index, items in enumerate(n_wise(search_in, item_count)):
        if search_for == items:
            return index
    return None


def remove_duplicate_points(shape):
    if len(shape) < 1:
        return shape
    ret = [shape[0]]
    for point in shape[1:]:
        if point == ret[-1]:
            continue
        ret.append(point)
    return tuple(ret)
