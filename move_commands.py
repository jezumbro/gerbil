def move_statement(*, x: float = 0, y: float = 0, z: float = 0):
    return f"move {x:.3f} {y:.3f} {z:.3f}"


def move_z_direction(speed: float, distance: float):
    return [f"speed {speed:.3f}", move_statement(z=distance)]


def print_statement(print_speed: float, *, x: float = 0, y: float = 0):
    return [f"speed {print_speed:.3f}", move_statement(x=x, y=y)]


def open_valve(distance: float, speed: float, delay: float):
    return [f"trigvalverel {distance:.3f} {speed:.3f}", f"wait {delay:.3f}"]


def close_valve(speed: float, delay: float):
    return [f"valverel 0.000 {speed:.3f}", f"wait {delay:.3f}"]
