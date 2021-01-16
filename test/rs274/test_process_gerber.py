from shapely.geometry import LineString, MultiPolygon, Polygon
from shapely.ops import cascaded_union

from rs274.process_gerber import merge_close_polygons


def test_simple_merge_close_polygons():
    p1 = LineString([(0, 0), (1, 0)]).buffer(0.5)
    p2 = LineString([(0, 1), (1, 1)]).buffer(0.495)
    shape = cascaded_union([p1, p2])
    print(type(shape))
    assert isinstance(shape, MultiPolygon)
    d = merge_close_polygons(shape)
    assert isinstance(d, Polygon)
    assert d.bounds