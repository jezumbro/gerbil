from itertools import chain
from typing import Iterable, List, Reversible, Tuple

import tripy
from shapely.geometry import Polygon

from util import pairwise


def make_side_triangles(path: List[Tuple[float, float]], height: float = 0.1):
    for point1, point2 in pairwise(path):
        yield from side_triangles_from_segment(point1, point2, height)


def side_triangles_from_segment(
    p1: Tuple[float, float], p2: Tuple[float, float], height: float
):
    yield (*p1, 0), (*p1, height), (*p2, height)
    yield (*p1, 0), (*p2, height), (*p2, 0)


def polygon_to_triangles(p: Polygon):
    return tripy.earclip(p.boundary.coords[:-1])


def add_z_coordinate(point2d: Tuple[float, float], height: float):
    return *point2d, height


def top_face(triangle: Iterable[Tuple[float, float]], height: float):
    return tuple(add_z_coordinate(point, height) for point in triangle)


def bottom_face(triangle: Reversible[Tuple[float, float]]):
    return tuple(add_z_coordinate(point, 0) for point in reversed(triangle))


def extrude_polygon(p: Polygon, height: float):
    triangles = list(polygon_to_triangles(p))
    top_triangles = [top_face(t, height) for t in triangles]
    bottom_triangles = [bottom_face(t) for t in triangles]
    side_triangles = list(make_side_triangles(p.boundary.coords, height))
    return chain(top_triangles, bottom_triangles, side_triangles)


def extrude_many_polygons(polygons: Iterable[Polygon], height=5):
    for polygon in polygons:
        yield from extrude_polygon(polygon, height)


if __name__ == "__main__":
    p = Polygon([(0, 0), (0, 50), (50, 50), (50, 0)])
    print(list(p.boundary.coords))
    from pprint import pprint

    # pprint(list(extrude_polygon(p, 5)))
    # test_make_sides()
