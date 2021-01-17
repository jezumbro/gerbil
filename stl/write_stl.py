import struct
from typing import List, Tuple, Iterable

ASCII_FACET = """  facet normal  {face[0]:e}  {face[1]:e}  {face[2]:e}
    outer loop
      vertex    {face[3]:e}  {face[4]:e}  {face[5]:e}
      vertex    {face[6]:e}  {face[7]:e}  {face[8]:e}
      vertex    {face[9]:e}  {face[10]:e}  {face[11]:e}
    endloop
  endfacet"""


def ascii_facet(facet: List[float]):
    return ASCII_FACET.format(face=facet)


BINARY_FACET = "12fH"


def binary_facet(facet: List[float]):
    return struct.pack(BINARY_FACET, *facet, 0)


BINARY_HEADER = "80sI"


def binary_stl(triangles: List[Tuple[float, float, float]]) -> bytes:
    triangles = list(triangles)
    return b"".join(
        (
            struct.pack(BINARY_HEADER, b"Binary STL Writer", len(triangles)),
            *(binary_facet(triangle_to_facet(triangle)) for triangle in triangles),
        )
    )


def triangle_to_facet(triangle) -> List[float]:
    normal = calculate_normal(triangle)
    return [dim for point in ([normal, *triangle]) for dim in point]


def ascii_stl(triangles: Iterable[Tuple[float, float, float]]) -> str:
    return "\n".join(
        (
            "solid shape",
            *(ascii_facet(triangle_to_facet(t)) for t in triangles),
            "endsolid shape",
        )
    )


def write_ascii_stl(triangles: List[Tuple[float, float, float]], file_name: str):
    with open(file_name, "w") as f:
        f.write(ascii_stl(triangles))


def write_binary_stl(triangles: List[Tuple[float, float, float]], file_name: str):
    with open(file_name, "wb") as f:
        f.write(binary_stl(triangles))


def calculate_normal(triangle):
    (x0, y0, z0), (x1, y1, z1), (x2, y2, z2) = triangle
    ux, uy, uz = [x1 - x0, y1 - y0, z1 - z0]
    vx, vy, vz = [x2 - x0, y2 - y0, z2 - z0]
    return uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
