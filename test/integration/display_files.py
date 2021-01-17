from conftest import simple_triangle
from stl.process_stl import extrude_many_polygons

if __name__ == "__main__":
    q = [simple_triangle]

    triangles = extrude_many_polygons(q, 5)
    from stl.write_stl import binary_stl
    from io import BytesIO
    import trimesh
    import pyrender

    with BytesIO() as f:
        f.write(binary_stl(triangles))
        f.seek(0)
        fuze_trimesh = trimesh.load(f, file_type="stl")

    mesh = pyrender.Mesh.from_trimesh(fuze_trimesh)
    scene = pyrender.Scene()
    scene.add(mesh)
    pyrender.Viewer(scene, use_raymond_lighting=True)
