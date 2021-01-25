from pathlib import Path
from tempfile import TemporaryDirectory

from configuration import read_config, save_config


def test_save_config():
    with TemporaryDirectory() as d:
        file = Path(d) / "settings.json"
        values = {"settings_slic3r_exe": "now"}
        save_config(values=values, path=file)
        r = read_config(file)
    assert r.slic3r_exe == "now"
