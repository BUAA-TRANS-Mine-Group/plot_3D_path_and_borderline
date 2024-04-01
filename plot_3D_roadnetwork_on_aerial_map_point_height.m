 

%% 输入
% 编写m代码实现功能：
% 1）读取 bitmap_mask 黑白栅格地图信息；
% 2）读取语义地图信息；
% 3）bitmap_mask与地理位置的关系如下：
% "bitmap_mask_PNG":{
% 		"png_version":"mask_20231115_2.png,20231115",
% 		"UTM_info":{
% 			"point_southwest":[909.4427,246.3298],
% 			"point_northeast":[3017.7427,1541.8298],
% 			"local_x_range":[909.4427,3017.7427],
% 			"local_y_range":[246.3298,1541.8298],
% 			"unit":"m"
% 		},
% 		"canvas_edge_meter":[2108.3,1295.5],
% 		"canvas_edge_pixel":[21083,12955],
% 		"scale_PixelPerMeter":10,
% 		"scale_MeterPerPixel":0.1
% 	},
% 4) 首先，对栅格bitmap_mask 可行驶道路部分（储存为0）进行三维空间建模：
% 对每个 bitmap_mask 可行驶部分（储存为0，白色区域）的栅格，在xy平面内 匹配所有参考路径的最近点，将该点的海拔高度信息作为栅格的高度信息；
% 然后，对所有可行驶区域栅格的海拔高度信息进行平滑处理，得到山路高地起伏平滑的建模；
% 
% 
% 5）如果我想要实现更加高级的功能：通过读取前后两个栅格 获取运动的坡度信息，应该如何进行；
% 
% 
% jsondata_semantic_map
% 
% jsondata_semantic_map = 
% 
%   包含以下字段的 struct:
% 
%                       version: '1.5'
%                 map_make_date: '2023-12-16'
%             infomation_of_map: 'modify reference path and borderline of jiangtong map using matlab'
%     CoordinateReferenceSystem: [1×1 struct]
%           local_origin_utm_xy: [2×1 double]
%           local_origin_lonlat: [2×1 double]
%                bitmap_rgb_PNG: [1×1 struct]
%               bitmap_mask_PNG: [1×1 struct]
%                          node: [711×1 struct]
%                    node_block: [10×1 struct]
%                       polygon: [66×1 struct]
%                          road: [42×1 struct]
%                  intersection: [15×1 struct]
%                  loading_area: [6×1 struct]
%                unloading_area: [3×1 struct]
%                    road_block: [2×1 struct]
%                   dubins_pose: [307×1 struct]
%                reference_path: [196×1 struct]
%                    borderline: [144×1 struct]
% jsondata_semantic_map.reference_path
% 
% ans = 
% 
%   包含以下字段的 196×1 struct 数组:
% 
%     token
%     type
%     link_polygon_tokens
%     link_dubinspose_tokens
%     incoming_tokens
%     outgoing_tokens
%     is_start_blocked
%     is_end_blocked
%     waypoint_sampling_interval_meter
%     waypoints
% 
%     waypoints 储存大量的路径点（每隔0.2米一个）的[x,y,yaw,height,slope]
 %%
clear;
close all;

%% 输入
bitmap_mask_path = 'D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\bitmap\guangdong_dapai_bitmap_mask.png';
bitmap_rgb = 'D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\bitmap\guangdong_dapai_bitmap_rgb.png';
semantic_map_path = "D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\semantic_map\guangdong_dapai_semantic_map.json";


%% 1) 读取语义地图信息
json_semantic_map = fileread(semantic_map_path);
jsondata_semantic_map = jsondecode(json_semantic_map);


%% 2) 读取 bitmap_mask 黑白栅格地图信息
% bitmap_mask = imread(bitmap_mask_path);
% bitmap_mask = bitmap_mask(:,:,1); % 确保bitmap_mask是二维数组
bit_mask.img =  imread(bitmap_mask_path,'png');
bit_mask.size =size(bit_mask.img);
bit_mask.height =bit_mask.size(1);
bit_mask.width =bit_mask.size(2);
% 指定绘制的x和y范围
bit_mask.x_range = jsondata_semantic_map.bitmap_mask_PNG.UTM_info.local_x_range;
bit_mask.y_range = jsondata_semantic_map.bitmap_mask_PNG.UTM_info.local_y_range;
bit_mask.img_y_reverse = flipud(bit_mask.img);%围绕水平轴按上下方向翻转其各行。
bit_mask.scale_PixelPerMeter=jsondata_semantic_map.bitmap_mask_PNG.scale_PixelPerMeter;
bit_mask.scale_MeterPerPixel=jsondata_semantic_map.bitmap_mask_PNG.scale_MeterPerPixel;
fprintf('###log### 读取地图数据\n');

%%  3）两种实现途径 :  每个栅格 获取高程信息；
flag_method = 1;
switch flag_method
    case 1
        % 两种实现途径1/2: 每个栅格点去匹配路径中的高程 ；totalPixels =273130265
        method_1_mask_point_match_Waypoints;
    case 2
        % 两种实现途径2/2: 称为"洪水填充"(Flood Fill)算法或“扩散填充”(Spread Filling)算法。
        method_2_Spread_Filling.m
end

  
%%  3.2）可视化高度矩阵
surf(heightMap);
title('3D Terrain Model');
xlabel('X');
ylabel('Y');
zlabel('Height');




 

%% 4）对高度信息进行平滑处理（可选）
% 你可以使用MATLAB内置函数如`imgaussfilt`进行高度信息的平滑处理
% Z_smoothed = imgaussfilt(Z, 2); % 示例：使用高斯滤波平滑处理，'2'是滤波器的标准差

%% 绘制三维地形图
% [X, Y] = meshgrid(1:cols, 1:rows);
% surf(X, Y, Z, 'EdgeColor', 'none');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% title('3D Model of Drivable Area');
