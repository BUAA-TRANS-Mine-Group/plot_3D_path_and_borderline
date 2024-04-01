% 首先，创建一个空的矩阵（或列表）用于记录每个栅格所对应的最近路径点及其高度信息。这个矩阵（或列表）的大小与栅格图像bit_mask.img_y_reverse相同。
% 遍历所有路径点，将每个路径点映射到其所在的栅格，并记录下该栅格对应的最近路径点信息（包括高度）。
% 遍历每个可行驶区域的栅格，查找其最近的含有路径点的栅格，并从中获取高度信息。
allWaypoints = [];

for i = 1:length(jsondata_semantic_map.reference_path)
    waypoints = jsondata_semantic_map.reference_path(i).waypoints;

    for j = 1:size(waypoints, 1)
        allWaypoints = [allWaypoints; waypoints(j, 1:2), waypoints(j, 4)]; % [x, y, height]
    end

end

fprintf('###log### 提取所有参考路径点及其高度信息,end.\n');

% 1. 初始化包含高度信息的栅格矩阵，先设置所有值为NaN表示未赋值
[rows, cols] = size(bit_mask.img_y_reverse);
mask_height = nan(rows, cols);
totalPixels = numel(mask_height);
% 2. 遍历所有路径点，更新栅格矩阵中的高度信息
for idx = 1:size(allWaypoints, 1)
    x_utm = allWaypoints(idx, 1);
    y_utm = allWaypoints(idx, 2);
    height = allWaypoints(idx, 3);

    % 将UTM坐标转换为栅格坐标
    col = round((x_utm - bit_mask.x_range(1)) / bit_mask.scale_MeterPerPixel) + 1;
    row = round((y_utm - bit_mask.y_range(1)) / bit_mask.scale_MeterPerPixel) + 1;

    % 检查坐标是否在图像范围内
    if row >= 1 && row <= rows && col >= 1 && col <= cols
        mask_height(row, col) = height;
    end

end

fprintf('###log### 遍历所有路径点，更新栅格矩阵中的高度信息,end.\n');

%% 3. 称为"洪水填充”(Flood Fill)算法或“扩散填充”(Spread Filling)算法。

% 其基本思路是从每个有确定高程的栅格出发，向四周扩散，直到填满所有可行驶区域的栅格。
% 这种方法对于填补高程数据的缺失区域非常有效，尤其是在高程变化平缓的区域。
mask_height = spreadFilling(Z = mask_height);

function mask_height = spreadFilling(Z)
    % 获取栅格的尺寸
    [rows, cols] = size(Z);

    % 初始化进度条
    hWaitBar = waitbar(0, 'Initializing flood fill process...');

    totalCells = rows * cols; % 计算总单元格数量
    filledCells = 0; % 初始化已处理的单元格数量

    updateFrequency = 50000; % 指定进度条更新的频率，例如每处理50000个像素后更新一次进度条

    % 遍历每个栅格
    for row = 1:rows

        for col = 1:cols
            % 检查当前栅格是否需要填充（即当前栅格是可行驶区域且高程信息为NaN）
            if isnan(Z(row, col)) && (bit_mask.img_y_reverse(row, col) >= 200) % 可行驶区域
                % 执行扩散填充算法
                Z = fillCurrentCell(Z, row, col);
            end

            filledCells = filledCells + 1; % 更新已处理的单元格数量

            % 每处理updateFrequency个像素后更新一次进度条
            if mod(filledCells, updateFrequency) == 0
                waitbar(filledCells / totalCells, hWaitBar, sprintf('Flood filling... %d%%', floor((filledCells / totalCells) * 100)));
            end

        end

    end

    % 确保在最后一次也更新进度条，以反映完成的状态
    waitbar(filledCells / totalCells, hWaitBar, 'Flood filling... 100%');

    % 完成后关闭进度条
    close(hWaitBar);
end

function Z = fillCurrentCell(Z, row, col, maxDistance)
    % fillCurrentCell则尝试找到当前栅格四周（上下左右）非NaN的栅格，并将找到的第一个非NaN栅格的高程赋值给当前栅格。
    % 获取栅格的尺寸
    [rows, cols] = size(Z);
    % 定义搜索的最大范围，防止无限递归
    if nargin < 4
        maxDistance = 10; % 可根据实际需要调整
    end

    % 从1开始逐步扩大搜索范围
    for distance = 1:maxDistance
        % 计算搜索边界
        rowMin = max(1, row - distance);
        rowMax = min(rows, row + distance);
        colMin = max(1, col - distance);
        colMax = min(cols, col + distance);

        % 搜索当前范围内的非NaN栅格
        found = false;

        for r = rowMin:rowMax

            for c = colMin:colMax
                % 检查是否为非NaN且在以当前栅格为中心的方形区域内
                if ~isnan(Z(r, c)) && (abs(r - row) == distance || abs(c - col) == distance)
                    Z(row, col) = Z(r, c); % 找到后赋值并结束搜索
                    found = true;
                    break;
                end

            end

            if found
                break;
            end

        end

        if found
            break; % 如果已经找到非NaN值，不需要进一步扩大搜索范围
        end

    end

    % 如果在最大距离内未找到非NaN值，则可以选择赋予默认高度值
    if ~found
        % Z(row, col) = defaultValue; % 选择一个合适的默认值
    end

end
