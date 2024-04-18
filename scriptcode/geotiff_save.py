import rasterio
from rasterio.transform import Affine
import numpy as np
import scipy.io as scio
import h5py

# 读取mask.mat文件获取占用信息
occupancy = scio.loadmat('mask.mat')
with h5py.File('heightMap.mat', 'r') as file:
    # 读取其中的数据集
    elevation = file['heightMap'][:]

# 将occupancy['map']转换为数组
occupancy_array = np.where(occupancy['map'] != 0, 1, 0)
elevation_array = elevation * occupancy_array
elevation_array[elevation_array == 0] = np.nan
# print(occupancy_array[12321,4321:4331])
# print(elevation_array[12321,4321:4331])
# 地理信息设置
transform = Affine.scale(0.1) * Affine.translation(559428.1239, 2580653.674)

# 设置UTM坐标系，根据您的地理位置选择合适的UTM区号
crs = "EPSG:32644"  # 示例EPSG代码，需根据实际情况修改

# 写入GeoTIFF
with rasterio.open(
    'raster_map_data.tif', 'w', driver='GTiff',
    height=elevation_array.shape[0], width=elevation_array.shape[1],
    count=1,  
    dtype=elevation_array.dtype,
    crs=crs,
    transform=transform
) as dst:
    dst.write(elevation_array, 1)  # 高程信息

print("GeoTIFF file has been created successfully.")


