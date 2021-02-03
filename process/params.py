from collections import defaultdict

from model import PrintParams
from util import get_interpolated_value, parse_float


def get_printing_params(values: dict) -> PrintParams:
    printing_params = parse_parameters(values)
    return PrintParams(
        **{
            k: get_interpolated_value(start, 0)
            for k, (start, end) in printing_params.items()
        }
    )


def parse_parameters(parameters):
    ret = defaultdict(list)
    for k, v in parameters.items():
        if type(k) is not str:
            continue
        new = format_key(k)
        if new not in PrintParams.parameters():
            continue
        ret[new].append(parse_float(v))
    for k, v in ret.items():
        if len(v) == 1:
            v.append(None)
    return ret


def format_key(k: str):
    return k.replace("_0", "").replace("_1", "").replace("line_", "")
