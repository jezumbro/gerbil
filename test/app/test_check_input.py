from validaton.main import good_input


def test_numeric_input():
    values = {"line_width": "0.100"}
    assert good_input("line_width", values)


def test_bad_input():
    values = {"line_width": "0.100q"}
    assert not good_input("line_width", values)
