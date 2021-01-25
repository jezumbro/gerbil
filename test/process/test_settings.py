from pathlib import Path
from pprint import pprint

import pytest

from configuration import read_config, write_config


def test_write_settings(tmp_path):
    file = Path(tmp_path) / "settings.json"
    s = write_config(file)
    pprint(s)
    assert file.is_file()


def test_read_settings(tmp_path):
    file = Path(tmp_path) / "settings.json"
    write_config(file)
    s = read_config(file)
    assert s.optimization_project == "optimization"
