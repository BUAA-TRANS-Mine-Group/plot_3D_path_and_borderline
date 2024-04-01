clear;
close all;

%% 输入
bitmap_mask = 'D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\bitmap\guangdong_dapai_bitmap_mask.png';
bitmap_rgb = 'D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\bitmap\guangdong_dapai_bitmap_rgb.png';
semantic_map = "D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\semantic_map\guangdong_dapai_semantic_map.json";

fprintf('###log### 读取地图数据\n');
json_semantic_map = fileread(semantic_map);
jsondata_semantic_map = jsondecode(json_semantic_map);

%% 绘图
% 生成一个新的 3D 图形窗口
figure;

% 读取底图
bit_rgb.img = imread(bitmap_rgb, 'png');
bit_rgb.size = size(bit_rgb.img);
bit_rgb.height = bit_rgb.size(1);
bit_rgb.width = bit_rgb.size(2);
%% 指定绘制的x和y范围
bit_rgb.x_range = jsondata_semantic_map.bitmap_rgb_PNG.UTM_info.local_x_range;
bit_rgb.y_range = jsondata_semantic_map.bitmap_rgb_PNG.UTM_info.local_y_range;
bit_rgb.img_y_reverse = flipud(bit_rgb.img); %围绕水平轴按上下方向翻转其各行。
% 获取底图大小和范围
xRange = bit_rgb.x_range;
yRange = bit_rgb.y_range;
zPlane = 0; % 底图放置的Z坐标

% 将底图转换为纹理贴图并放置在3D图中的特定位置
surf([xRange(1), xRange(2)], [yRange(1), yRange(2)], [zPlane, zPlane; zPlane, zPlane], ...
    'CData', bit_rgb.img_y_reverse, 'FaceColor', 'texturemap', 'EdgeColor', 'none');
hold on;

% 绘制3D路网
for i = 1:length(jsondata_semantic_map.borderline)
    points_XYZ = jsondata_semantic_map.borderline(i).borderpoints;
    X = points_XYZ(:, 1);
    Y = points_XYZ(:, 2);
    Z = points_XYZ(:, 3);
    scatter3(X, Y, Z, 1, [0.0, 0.0, 0.0], 'filled');
    hold on;
end

% 为每个reference_path设置颜色
colors = lines(length(jsondata_semantic_map.reference_path));

for i_path = 1:length(jsondata_semantic_map.reference_path)
    points_XYYawZ = jsondata_semantic_map.reference_path(i_path).waypoints;
    X = points_XYYawZ(:, 1);
    Y = points_XYYawZ(:, 2);
    Z = points_XYYawZ(:, 4);
    scatter3(X, Y, Z, 1, colors(i_path, :), 'filled', 'UserData', i_path);
    hold on;
end

% 设置图形属性
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal;
title('3D Road Net with RGB Base Map');
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'DisplayStyle', 'datatip', 'SnapToDataVertex', 'on', 'Enable', 'on');
set(dcm_obj, 'UpdateFcn', @customDatatip_refpathID_3D);
hold off;

fprintf('###log### 绘制完成。\n');
