from pathlib import Path
from pprint import pprint
from tempfile import TemporaryDirectory

from process import save_recipe


def test_save_process():
    with TemporaryDirectory() as d:
        file = Path(d) / "settings.json"
        settings = {}
        save_recipe({"recipe_name": "test", "line_width_0": "0.1"}, settings, path=file)
        pprint(settings)
        assert file.is_file()
        assert settings["recipes"]
