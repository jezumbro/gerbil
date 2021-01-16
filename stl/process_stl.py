from itertools import chain
from typing import List, Tuple, Iterable, Reversible
import tripy
from shapely.geometry import LinearRing, Polygon
from sparkles import pairwise


def make_side_triangles(path: List[Tuple[float, float]], height: float = 0.1):
    for point1, point2 in pairwise(path):
        yield from side_triangles_from_segment(point1, point2, height)


def side_triangles_from_segment(
    p1: Tuple[float, float], p2: Tuple[float, float], height: float
):
    yield (*p1, 0), (*p2, height), (*p1, height)
    yield (*p1, 0), (*p2, height), (*p2, 0)


def polygon_to_triangles(p: Polygon):
    lr: LinearRing = LinearRing(p.boundary)
    return tripy.earclip(lr.coords[:-1])


def add_z_coordinate(point2d: Tuple[float, float], height: float):
    return *point2d, height


def top_face(triangle: Iterable[Tuple[float, float]], height: float):
    return tuple(add_z_coordinate(point, height) for point in triangle)


def bottom_face(triangle: Reversible[Tuple[float, float]]):
    return tuple(add_z_coordinate(point, 0) for point in reversed(triangle))


def extrude_polygon(p: Polygon, height: float):
    triangles = polygon_to_triangles(p)
    top_triangles = [top_face(t, height) for t in triangles]
    bottom_triangles = [bottom_face(t) for t in triangles]
    side_triangles = list(make_side_triangles(p.boundary, height))
    return chain(top_triangles, bottom_triangles, side_triangles)


def extrude_many_polygons(polygons: Iterable[Polygon], height=5):
    return [extrude_polygon(polygon, height) for polygon in polygons]


if __name__ == "__main__":
    p = Polygon([(0, 0), (0, 50), (50, 50), (50, 0)])
    from pprint import pprint

    pprint(list(extrude_polygon(p, 5)))
    # test_make_sides()
