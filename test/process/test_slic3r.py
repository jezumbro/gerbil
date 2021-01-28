import os

from settings import config


def test_call_slic3r():
    q = os.system(f"{config.slic3r_exe} --help-fff")
    print(q)
    # assert False
