from configuration import config_path, read_config, write_config


def get_recipes():
    pass


def startup():
    if config_path.is_file():
        return read_config()
    return write_config()


if __name__ == "__main__":
    startup()
