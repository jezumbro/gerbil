from pprint import pprint

from process.model import PrintParams
from process.system_files import (format_line, format_optimization_job_lines,
                                  open_valve)


def test_open_valve():
    q = open_valve(0.1001, 18, 0)
    assert len(q) == 2
    assert "18.000" in q[0]
    assert "0.1001" not in q[0]
    assert "0.100" in q[0]


def test_format_line():
    params = PrintParams()
    q = format_line(params, 10, 0.5)


def test_format_op(app_values):
    q = format_optimization_job_lines(app_values)
