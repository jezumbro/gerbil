from conftest import simple_triangle
from stl.process_stl import extrude_many_polygons

if __name__ == "__main__":
    q = [simple_triangle]

    triangles = extrude_many_polygons(q, 5)
    from stl.write_stl import write_ascii_stl

    write_ascii_stl(triangles, "test.stl")
    import trimesh
    import pyrender

    fuze_trimesh = trimesh.load("test.stl")
    mesh = pyrender.Mesh.from_trimesh(fuze_trimesh)
    scene = pyrender.Scene()
    scene.add(mesh)
    pyrender.Viewer(scene, use_raymond_lighting=True)
