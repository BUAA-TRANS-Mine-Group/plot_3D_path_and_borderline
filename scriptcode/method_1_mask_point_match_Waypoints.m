%% 获取所有路径点
allWaypoints = [];

for i = 1:length(jsondata_semantic_map.reference_path)
    waypoints = jsondata_semantic_map.reference_path(i).waypoints;

    for j = 1:size(waypoints, 1)
        allWaypoints = [allWaypoints; waypoints(j, 1:2), waypoints(j, 4)]; % [x, y, height]
    end

end

fprintf('###log### 提取所有参考路径点及其高度信息,end.\n');

%% 1. 构建空间索引
% 首先，使用路径点构建一个空间索引。在Matlab中，可以使用KDTreeSearcher对象来实现：
% 假设allWaypoints是一个Nx3的矩阵，其中列分别代表x坐标，y坐标和高度
X = allWaypoints(:, 1:2); % 只取x，y坐标用于构建k-d树
kdTree = KDTreeSearcher(X);
fprintf('###log### kdTree构建完成.\n');

% 计算UTM坐标矩阵
[rows, cols] = size(bit_mask.img_y_reverse);
[X_utm, Y_utm] = meshgrid( ...
    linspace(bit_mask.x_range(1), bit_mask.x_range(2), cols), ...
    linspace(bit_mask.y_range(1), bit_mask.y_range(2), rows));
X_utm = X_utm';
Y_utm = Y_utm';
%%  非并行处理 和并行处理

% 初始化高度矩阵，所有值设置为NaN
[rows, cols] = size(bit_mask.img_y_reverse);
totalPixels = numel(mask_height);
heightMap = nan(rows, cols);
% 接下来，对于图像中的每个像素点，使用k-d树找到最近的路径点，并记录这个距离和高度值：

flag_is_mulit_processed = true;
% flag_is_mulit_processed = false;

if ~flag_is_mulit_processed
    % 非并行处理
    hWaitBar = waitbar(0, '正在处理高度数据...', 'Name', '进度');
    totalPixels = numel(heightMap);
    processedPixels = 0;
    updateFrequency = 10000; % 每处理10000个像素点更新一次进度条

    for col = 1:cols

        for row = 1:rows

            if bit_mask.img_y_reverse(row, col) >= 200
                [idx, dist] = knnsearch(kdTree, [X_utm(row, col), Y_utm(row, col)]);
                heightMap(row, col) = allWaypoints(idx, 3);
            end

            processedPixels = processedPixels + 1;

            if mod(processedPixels, updateFrequency) == 0
                waitbar(processedPixels / totalPixels, hWaitBar);
            end

        end

    end

    close(hWaitBar);
else % 如果资源允许，可以采用并行处理来进一步加速这个过程。在Matlab中，可以使用parfor循环来实现：
    % 并行处理
    if isempty(gcp('nocreate'))
        parpool; % 启动并行池
    end

    parfor col = 1:cols
        tempHeight = nan(rows, 1);

        for row = 1:rows

            if bit_mask.img_y_reverse(row, col) >= 200
                [idx, dist] = knnsearch(kdTree, [X_utm(row, col), Y_utm(row, col)]);
                tempHeight(row) = allWaypoints(idx, 3);
            end

        end

        heightMap(:, col) = tempHeight;
        fprintf('###log###  col = %d end.\n', col);
    end

    delete(gcp('nocreate')); % 关闭并行池
end

fprintf('###log### 所有栅格点已经匹配了高度信息.\n');
