import rasterio
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# 读取.tif文件
with rasterio.open('smoothed_elevation.tif', 'r') as src:
    smoothed_elevation = src.read(1)  # 读取第一个波段的数据

    # 获取地理转换信息
    transform = src.transform

    # 获取地图投影信息
    crs = src.crs

# 创建三维坐标网格
x = np.arange(0, smoothed_elevation.shape[1], 1)
y = np.arange(0, smoothed_elevation.shape[0], 1)
x, y = np.meshgrid(x, y)

# 创建三维图形对象
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# 绘制三维曲面图
surf = ax.plot_surface(x, y, smoothed_elevation, cmap='viridis')

# 设置坐标轴标签
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Elevation')
ax.set_box_aspect([1,2,0.2])
# 添加颜色条
fig.colorbar(surf)

# 显示图形
plt.show()
