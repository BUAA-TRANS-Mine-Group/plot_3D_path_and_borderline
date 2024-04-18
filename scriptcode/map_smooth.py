import numpy 
import rasterio
from scipy.ndimage import gaussian_filter

# 假设已经打开了GeoTIFF文件并读取了第二层的高程数据
with rasterio.open('raster_map_data.tif') as dataset:
    elevation_data = dataset.read(1)

# 应用高斯平滑，sigma是高斯核的标准差，决定平滑的程度
smoothed_elevation = gaussian_filter(elevation_data, sigma=3)

# 保存平滑后的高程数据回GeoTIFF文件
with rasterio.open(
    'smoothed_elevation.tif', 'w',
    driver='GTiff',
    height=dataset.height, width=dataset.width,
    count=1,
    dtype=smoothed_elevation.dtype,
    crs=dataset.crs,
    transform=dataset.transform
) as dst:
    dst.write(smoothed_elevation, 1)