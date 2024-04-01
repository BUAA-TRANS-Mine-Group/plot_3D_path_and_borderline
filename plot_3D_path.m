%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 脚本开发环境：MATLAB R2020b
% 作者：陈志发;
% 邮箱：chenzhifa@buaaa.edu.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close
%% 输入

bitmap_mask = 'D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\bitmap\guangdong_dapai_bitmap_mask.png';
bitmap_rgb = 'D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\bitmap\guangdong_dapai_bitmap_rgb.png';
semantic_map = "D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\semantic_map\guangdong_dapai_semantic_map.json";

fprintf('###log###  读取地图数据\n');
json_semantic_map = fileread(semantic_map);
jsondata_semantic_map = jsondecode(json_semantic_map);

%% 绘图

%%
if 1
    % 生成一个新的 3D 图形窗口
    figure;

    for i = 1:length(jsondata_semantic_map.borderline)
        % 获取每个 borderline 的 borderpoints
        points_XYZ = jsondata_semantic_map.borderline(i).borderpoints;
        % 提取 X, Y, Z 坐标
        X = points_XYZ(:, 1);
        Y = points_XYZ(:, 2);
        Z = points_XYZ(:, 3);
        % 绘制 3D 散点图
        scatter3(X, Y, Z, 1, [0.0, 0.0, 0.0], 'filled'); % 'filled' 表示填充散点
        hold on;
    end

    % 为每个 reference_path 设置一个颜色
    colors = lines(length(jsondata_semantic_map.reference_path));
    % 遍历 jsonData.reference_path
    for i_path = 1:length(jsondata_semantic_map.reference_path)
        % 获取每个 reference_path 的 borderpoints
        points_XYYawZ = jsondata_semantic_map.reference_path(i_path).waypoints;
        % 提取 X, Y, Z 坐标
        X = points_XYYawZ(:, 1);
        Y = points_XYYawZ(:, 2);
        Z = points_XYYawZ(:, 4);
        % 绘制 3D 散点图
        scatterHandle = scatter3(X, Y, Z, 1, colors(i_path, :), 'filled', 'UserData', i_path); % 'filled' 表示填充散点
        hold on;
    end

    % 设置图形的坐标轴标签
    xlabel('X'); ylabel('Y'); zlabel('Z');
    % 设置坐标轴的比例尺
    axis equal;
    % 设置图形的标题
    title('3D Road Network: Border line and Reference path');
    % 游标指示
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'DisplayStyle', 'datatip', 'SnapToDataVertex', 'on', 'Enable', 'on');
    set(dcm_obj, 'UpdateFcn', @customDatatip_refpathID_3D); % Set the callback here

    % 完成绘图
    hold off;

end

fprintf(' ###log### 绘制完成，5.\n');
