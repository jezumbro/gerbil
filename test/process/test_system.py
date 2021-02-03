from pprint import pprint

from move_commands import open_valve
from process.params import get_printing_params
from process.system_files import format_optimization_job_lines


def test_open_valve():
    q = open_valve(0.1001, 18, 0)
    assert len(q) == 2
    assert "18.000" in q[0]
    assert "0.1001" not in q[0]
    assert "0.100" in q[0]


def test_format_op(app_values):
    lines = format_optimization_job_lines(app_values)
    action_lines = [l for l in lines if not l.startswith("//")]
    move_lines = [l.split(" ")[1:] for l in action_lines if l.startswith("move")]
    relative_x = [float(x[0]) for x in move_lines]
    relative_y = [float(x[1]) for x in move_lines]
    relative_z = [float(x[2]) for x in move_lines]
    absolute_z = []
    params = get_printing_params(app_values)
    last_z = 0
    for z in relative_z:
        new_z = last_z + z
        absolute_z.append(last_z + z)
        last_z = new_z
    pprint(list(zip(relative_z, absolute_z)))

    assert sum(relative_x) == 0
    assert sum(relative_y) == 5.0
    assert round(sum(relative_z), 1) == 0.5
