from shapely.geometry import MultiPolygon


def plot(polygons: MultiPolygon):
    from matplotlib import pyplot as plt

    if isinstance(polygons, MultiPolygon):
        for polygon in polygons:
            plt.plot(*polygon.exterior.xy)
    plt.show()
