from pprint import pprint

import pytest
from gerber.primitives import Arc, Circle
from shapely.geometry import LineString, MultiPolygon, Polygon
from shapely.ops import cascaded_union

from rs274.primitives import (
    find,
    fix_region,
    inner_polygons,
    process_arc,
    remove_duplicate_points,
)
from rs274.process_gerber import merge_close_polygons
from util import first


def test_simple_merge_close_polygons():
    p1 = LineString([(0, 0), (1, 0)]).buffer(0.5)
    p2 = LineString([(0, 1), (1, 1)]).buffer(0.495)
    shape = cascaded_union([p1, p2])
    print(type(shape))
    assert isinstance(shape, MultiPolygon)
    d = merge_close_polygons(shape)
    assert isinstance(d, Polygon)
    assert d.bounds


@pytest.mark.skip
def test_simple_region(simple_region_with_hole):
    p = fix_region(simple_region_with_hole)
    assert isinstance(p, MultiPolygon)


@pytest.mark.skip
def test_complex_region(complex_region_with_holes):
    p = fix_region(complex_region_with_holes)
    assert isinstance(p, MultiPolygon)


def test_inner_polygons_length(simple_region_with_hole):
    assert len(list(inner_polygons(simple_region_with_hole))) == 1


def test_nested_polygons_length(simple_region_with_nested_hole):
    assert len(list(inner_polygons(simple_region_with_nested_hole))) == 2


def test_inner_polygon_points(simple_region_with_hole):
    poly = first(inner_polygons(simple_region_with_hole))
    expected = (
        (8, 5),
        (8, 2),
        (2, 2),
        (2, 8),
        (8, 8),
        (8, 5),
    )
    assert poly == expected


def test_find():
    assert find(tuple("DEF"), tuple("ABCDEFG")) == 3


def test_find_with_longer_strings():
    assert not find(tuple("DEF"), tuple("A"))


def test_find_doesnt_false_positive():
    assert not find(tuple("DEF"), tuple("FEDA"))


def test_remove_duplicate_points():
    in_data = ((1.0, 2.0), (1.0, 2.0))
    assert remove_duplicate_points(in_data) == ((1, 2),)


def test_remove_duplicate_points_no_dups():
    in_data = ((1.0, 2.0), (1.0, 3.0))
    assert remove_duplicate_points(in_data) == ((1, 2), (1, 3))


def test_process_arc():
    a = Arc(
        start=(0, 0),
        end=(0, 0),
        center=(1, 0),
        direction="counterclockwise",
        aperture=Circle(None, 0.01, 0),
        quadrant_mode="multi-quadrant",
        level_polarity="dark",
    )
    q = list(process_arc(a))
    assert len(q) == 20
    assert q[-1] == q[0]


def test_nested_polygon_shapes(simple_region_with_nested_hole):
    first = (
        (9, 5),
        (9, 2),
        (6, 2),
        (6, 5),
        (6, 7),
        (9, 7),
        (9, 5),
    )

    second = (
        (4, 5),
        (4, 2),
        (1, 2),
        (1, 7),
        (4, 7),
        (4, 5),
    )

    polys = inner_polygons(simple_region_with_nested_hole)
    pprint(polys)
    assert second in polys, "second not found"
    assert first in polys, "first not found"


@pytest.mark.skip
def test_triple_nested_holes(triple_nested_holes):
    polys = inner_polygons(triple_nested_holes)
    pprint(polys)
    assert len(polys) == 3
