import pytest

from stl.process_stl import make_sides, side_triangles
from stl.write_stl import calculate_normal


@pytest.mark.skip
def test_make_sides_simple():
    coords = [(0, 0), (1, 0)]
    o = make_sides(coords)
    assert len(o) == 2


def test_side_triangles():
    p1 = (0, 0)
    p2 = (0, 1)
    height = 0.1
    triangles = list(side_triangles(p1, p2, height))
    t1 = triangles[0]
    t2 = triangles[1]
    assert len(triangles) == 2
    assert all(len(q) == 3 for q in triangles)
    assert (*p1, 0) == t1[0]
    assert (*p2, height) == t1[1]
    assert (*p1, height) == t1[2]
    assert (*p1, 0) == t2[0]
    assert (*p2, height) == t2[1]
    assert (*p2, 0) == t2[2]


def test_calculate_normal():
    p = [(0, 0, 0), (0, 1, 0), (1, 0, 0)]
    normal = calculate_normal(p)
    assert normal == (0, 0, -1)
