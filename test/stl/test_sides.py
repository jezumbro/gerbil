from stl.process_stl import (
    side_triangles_from_segment,
    make_side_triangles,
    add_z_coordinate,
    top_face,
    bottom_face,
)


def test_side_triangles():
    p1 = (0, 0)
    p2 = (0, 1)
    height = 0.1
    triangles = list(side_triangles_from_segment(p1, p2, height))
    t1 = triangles[0]
    t2 = triangles[1]
    assert len(triangles) == 2
    assert all(len(q) == 3 for q in triangles)
    assert (*p1, 0) == t1[0]
    assert (*p1, height) == t1[1]
    assert (*p2, height) == t1[2]
    assert (*p1, 0) == t2[0]
    assert (*p2, height) == t2[1]
    assert (*p2, 0) == t2[2]


def test_make_sides_for_line_makes_2_triangles():
    p = [(0, 0), (0, 50)]
    assert len(list(make_side_triangles(p))) == 2


def test_make_sides_for_line_makes_same_as_side_triangles():
    p = [(0, 0), (0, 50)]
    out = list(make_side_triangles(p, 1))
    expected = list(side_triangles_from_segment(p[0], p[1], 1))
    assert out == expected


def test_make_sides_for_2_lines_makes_4_triangles():
    p = [(0, 0), (0, 50), (50, 50)]
    assert len(list(make_side_triangles(p))) == 4


def test_add_z_coordinate():
    point = 1, 2
    assert add_z_coordinate(point, 3) == (1, 2, 3)


def test_top_face():
    triangle = (0, 0), (1, 0), (0, 1)
    assert top_face(triangle, 3) == ((0, 0, 3), (1, 0, 3), (0, 1, 3))


def test_bottom_face():
    triangle = (0, 0), (1, 0), (0, 1)
    assert bottom_face(triangle) == ((0, 1, 0), (1, 0, 0), (0, 0, 0))
