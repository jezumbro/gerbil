from stl.write_stl import calculate_normal


def test_calculate_normal():
    p = [(0, 0, 0), (0, 1, 0), (1, 0, 0)]
    normal = calculate_normal(p)
    assert normal == (0, 0, -1)
