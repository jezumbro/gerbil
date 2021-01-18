from itertools import permutations
from pathlib import Path

from gerber import read as gerber_read
from gerber.rs274x import GerberFile
from shapely.geometry import CAP_STYLE, JOIN_STYLE, MultiPolygon
from shapely.ops import cascaded_union

from rs274.primitives import lookup
from settings import config
from stl.process_stl import extrude_many_polygons


def plot(polygons):
    from matplotlib import pyplot as plt

    if isinstance(polygons, MultiPolygon):
        for polygon in polygons:
            plt.plot(*polygon.exterior.xy)
    plt.show()


def create_polygons(file_name: str = None):
    p = Path(file_name)
    layer: GerberFile = gerber_read(p.absolute())
    missing = set()
    dark = []
    for idx, primitive in enumerate(layer.primitives):
        key = type(primitive), primitive.level_polarity
        if func := lookup.get(key):
            dark.append(func(primitive))
            continue
        missing.add(key)
    poly = cascaded_union(dark)
    return merge_close_polygons(poly)


def merge_close_polygons(shape, eps: float = config.eps):
    return shape.buffer(
        distance=eps, cap_style=CAP_STYLE.square, join_style=JOIN_STYLE.mitre
    ).buffer(distance=-eps, cap_style=CAP_STYLE.square, join_style=JOIN_STYLE.mitre)


def inner_polygons(shape):
    shape = shape[1:]
    seen = []
    shapes = set()
    for current_index, point in enumerate(shape):
        if point not in seen:
            seen.append(point)
        else:
            idx = shape.index(point)
            raw = shape[idx : current_index + 1]
            trimmed = trim_shape(raw)
            de_duped = remove_duplicate_points(trimmed)
            shapes.add(de_duped)

    for shape1, shape2 in list(permutations(shapes, 2)):
        if index := find(shape1, shape2):
            new_shape = shape2[:index] + shape2[index + len(shape1) :]
            shapes.add(tuple(remove_duplicate_points(new_shape)))
            if shape2 in shapes:
                shapes.remove(shape2)
    return tuple(shapes)


def trim_shape(shape):
    if len(shape) <= 4:
        return shape
    if shape[0] == shape[-1] and shape[1] == shape[-2]:
        return tuple(shape[1:-1])
    return tuple(shape)


def find(search_for, search_in):
    if len(search_for) > len(search_in):
        return None

    item_count = len(search_for)
    for index, items in enumerate(n_wise(search_in, item_count)):
        if search_for == items:
            return index
    return None


def remove_duplicate_points(shape):
    if len(shape) < 1:
        return shape
    ret = [shape[0]]
    for point in shape[1:]:
        if point == ret[-1]:
            continue
        ret.append(point)
    return tuple(ret)


if __name__ == "__main__":
    q = create_polygons(config.design_file)
    plot(q)
    triangles = extrude_many_polygons(q, 1)
    from stl.write_stl import write_ascii_stl

    write_ascii_stl(triangles, "test.stl")
    import pyrender
    import trimesh

    fuze_trimesh = trimesh.load("test.stl")
    mesh = pyrender.Mesh.from_trimesh(fuze_trimesh)
    scene = pyrender.Scene()
    scene.add(mesh)
    pyrender.Viewer(scene, use_raymond_lighting=True)
