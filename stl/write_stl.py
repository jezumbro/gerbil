from typing import List, Tuple

ASCII_FACET = """  facet normal  {face[0]:e}  {face[1]:e}  {face[2]:e}
    outer loop
      vertex    {face[3]:e}  {face[4]:e}  {face[5]:e}
      vertex    {face[6]:e}  {face[7]:e}  {face[8]:e}
      vertex    {face[9]:e}  {face[10]:e}  {face[11]:e}
    endloop
  endfacet"""


def _build_ascii_stl(triangles: List[Tuple[float, float, float]]):
    lines = [
        "solid shape",
    ]
    for triangle in triangles:
        print(triangle)
        normal = calculate_normal(triangle)
        face = [dim for point in ([normal, *triangle]) for dim in point]
        lines.append(ASCII_FACET.format(face=face))
    lines.append("endsolid shape")
    return lines


def write_stl(triangles, file_name):
    f = open(file_name, "wb")
    lines = _build_ascii_stl(triangles)
    lines_ = "\n".join(lines).encode("UTF-8")
    f.write(lines_)
    f.close()


def calculate_normal(triangle):
    (x0, y0, z0), (x1, y1, z1), (x2, y2, z2) = triangle
    ux, uy, uz = [x1 - x0, y1 - y0, z1 - z0]
    vx, vy, vz = [x2 - x0, y2 - y0, z2 - z0]
    return uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
