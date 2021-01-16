from itertools import chain
from pprint import pprint
from typing import List, Tuple

import tripy
from shapely.geometry import LinearRing, Polygon
from sparkles import pairwise

from stl.write_stl import write_stl


def side_triangles(p1: Tuple[float, float], p2: Tuple[float, float], height: float):
    yield (*p1, 0), (*p2, height), (*p1, height)
    yield (*p1, 0), (*p2, height), (*p2, 0)


def process_polygon(p: Polygon, height: float):
    lr: LinearRing = LinearRing(p.boundary)
    triangles = tripy.earclip(lr.coords[:-1])
    bottom = []
    top = []
    for triangle in triangles:
        bottom.append([(*t, 0) for t in reversed(triangle)])
        top.append([(*t, height) for t in triangle])
    side = list(make_sides(lr.coords, height))
    return list(chain(top, bottom, *side))


def process_complex_shape(multi_polygons, height=5):
    ret = []
    for polygon in multi_polygons:
        ret.extend(process_polygon(polygon, height))
    write_stl(ret, "output.stl")


def make_sides(coords: List[Tuple[float, float]], height: float = 0.1):
    return (list(side_triangles(o, d, height)) for (o, d) in pairwise(coords))


if __name__ == "__main__":
    p = Polygon([(0, 0), (0, 50), (50, 50), (50, 0)])
    q = process_polygon(p, 1)
    pprint(q)
    # test_make_sides()
