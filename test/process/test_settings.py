from pathlib import Path
from pprint import pprint
from tempfile import TemporaryDirectory

import pytest

from process.configuration import read_config, write_config


def test_write_settings():
    with TemporaryDirectory() as d:
        file = Path(d) / "settings.json"
        s = write_config(file)
        pprint(s)
        assert file.is_file()


def test_read_settings():
    with TemporaryDirectory() as d:
        file = Path(d) / "settings.json"
        write_config(file)
        s = read_config(file)
        assert s.optimization_project == "optimization"
