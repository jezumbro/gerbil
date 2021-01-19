from validaton.main import good_float


def test_numeric_input():
    values = {"line_width": "0.100"}
    assert good_float("line_width", values)


def test_bad_input():
    values = {"line_width": "0.100q"}
    assert not good_float("line_width", values)
