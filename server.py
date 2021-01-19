import requests

from configuration import read_config


def post_data(process: str, data: dict):
    config = read_config()
    try:
        r = requests.post(
            "https://gerbil.cld.vogelcc.com/",
            json={
                "psk": "gerberman",
                "uuid": config.uuid,
                "type": process,
                "data": data,
            },
        )
    except Exception as e:
        pass
