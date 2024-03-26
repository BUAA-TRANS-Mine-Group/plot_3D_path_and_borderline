

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
semantic_map="D:\BUAA_PhD\A1_Project\20230725-onsite比赛第二届非结构化道路赛道\onsite-mine非结构赛题\maps\semantic_map\guangdong_dapai_semantic_map.json";


fprintf('[###log###  读取地图数据\n');
json_semantic_map = fileread(semantic_map);
jsondata_semantic_map = jsondecode(json_semantic_map);

% if ~strcmp(jsondata_mapinfo.map_make_date, '2023.06.25') % 校验
%     % 在这里插入错误处理或其他代码
%     error('jiangtong_map_info.json的日期不正确，同时请确保与 jiangtong_drivable_area.png 匹配!');
% end



%%
bit_rgb.img =  imread(bitmap_rgb,'png');
bit_rgb.size = size(bit_rgb.img);
bit_rgb.height =bit_rgb.size(1);
bit_rgb.width =bit_rgb.size(2);
%% 指定绘制的x和y范围
bit_rgb.x_range = jsondata_semantic_map.bitmap_rgb_PNG.UTM_info.local_x_range;
bit_rgb.y_range =  jsondata_semantic_map.bitmap_rgb_PNG.UTM_info.local_y_range;

%%
bit_rgb.img_y_reverse = flipud(bit_rgb.img);%围绕水平轴按上下方向翻转其各行。


bit_mask.img =  imread(bitmap_mask,'png');
bit_mask.size =size(bit_mask.img);
bit_mask.height =bit_mask.size(1);
bit_mask.width =bit_mask.size(2);
% 指定绘制的x和y范围
bit_mask.x_range = jsondata_semantic_map.bitmap_mask_PNG.UTM_info.local_x_range;
bit_mask.y_range = jsondata_semantic_map.bitmap_mask_PNG.UTM_info.local_y_range;
bit_mask.img_y_reverse = flipud(bit_mask.img);%围绕水平轴按上下方向翻转其各行。

% x_origin = jsondata_mapinfo.UTM_local_origin_xy(1);
% y_origin = jsondata_mapinfo.UTM_local_origin_xy(2);

fprintf('[###log###  读取地图数据 end.\n');
 
%% test：地图验证
if 1 % bitmap_rgb 图

%  绘制rgb.png在指定的坐标范围

% 创建一个新的图像窗口
figure;
% 将像素绘制在指定的范围内
imshow(bit_rgb.img_y_reverse, 'InitialMagnification', 'fit', 'XData', bit_rgb.x_range, 'YData', bit_rgb.y_range);  hold on;
% % set(gca, 'XDir', 'reverse');hold on;
% scatter(XYcoordinate_all(:,1),XYcoordinate_all(:,2), 1,[3, 115, 101]/255);  hold on;%全部轨迹
set(gca, 'YDir', 'normal');hold on;
xlabel('X-UTM[m]'); ylabel('Y-UTM[m])');  title('bit rgb 图');
% xlim([xlim_min,xlim_max]);ylim([ylim_min, ylim_max])
axis equal;% 调整坐标轴纵横比
axis on;
end
%%
if 1  % bit_mask 图
%     绘制mak.png在指定的坐标范围
figure;
% 将像素绘制在指定的范围内
imshow(bit_mask.img_y_reverse, [0 1] ,'InitialMagnification', 'fit', 'XData',bit_mask. x_range, 'YData', bit_mask.y_range); 
% colormap(gray(2)); % This ensures that 0 is mapped to black and 1 is mapped to white
hold on;
% scatter(XYcoordinate_all(:,1),XYcoordinate_all(:,2), 1,[3, 115, 101]/255);  hold on;%全部轨迹
% set(gca, 'YDir', 'normal');hold on;
xlabel('X-UTM[m]'); ylabel('Y-UTM[m])');  title('bit mask 图');
axis equal;% 调整坐标轴纵横比
axis on;

    
    
end

 


