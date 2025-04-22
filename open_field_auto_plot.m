clc;clear;
seqNm={'F:\Three-chamber-saline\camera 1.seq'}; %tracking video
for i = 1:length(seqNm)
    % 获取当前文件路径
    seqFile = seqNm{i};

    % 使用 seqIo 函数获取文件信息
    info = seqIo(seqFile, 'getInfo');
    numFrames = info.numFrames;
    fprintf('文件 %s 包含 %d 帧。\n', seqFile, numFrames);
end

for i =1:length(seqNm)% seqNm is a cell that contains names of all seq files to be tracked.
    info=seqIo(seqNm{i},'getinfo'); n = info.numFrames;
    sr = seqIo(seqNm{i}, 'reader');
    sr.seek(1); I=sr.getframe(); figure; imshow(I); gca; title('select the detection/cage area');
    bw{i}=roipoly; %select a region to be tracked usually the bottom of the cage
%     bw{i}=drawpolygon
    bnds{i} = [0 n];
    types{i} = {'R'};
    Perm(i).resize = 0; Perm(i).mask = bw{i}; Perm(i).ILcorrect =1;
end


for i =1:length(seqNm)
    tic; mouseTrackerRun(seqNm{i}, bnds{i}, types{i}, Perm(i));toc
    trkNm_T = regexprep(seqNm{i},'.seq','-track.mat');
    load(trkNm_T)
    PosT=[];Pos = [];
    for m = 1:length(Y)
        Pos(m,:) = Y{1,1,m}(1,:);
    end
    PosT(:,1) = smooth(Pos(:,1), 15);
    PosT(:,2) = smooth(Pos(:,2), 15);
    trkNm_T_smooth =regexprep(trkNm_T,'-track.mat','-track_smooth.mat');
    for m=1:length(Y)
        Y{1,1,m} = PosT(m,:);
    end
    save(trkNm_T_smooth, 'Y');
end

for i =1:length(seqNm)% seqNm is a cell that contains names of all seq files to be tracked.
    info=seqIo(seqNm{i},'getinfo'); 
    sr = seqIo(seqNm{i}, 'reader');
    sr.seek(1); I=sr.getframe(); figure; imshow(I); gca; title('select the vertex');
end
ROI=drawpolygon;
polygon=ROI.Position ;
save roi_polygon polygon
hgsave(gcf,'RTCPP.tif')

%% plot routes and speed
start=1; %start frame
YY=squeeze(Y);
for n=start+1:numFrames;
data=YY{n,1};
xloc(n-start)=data(1);
yloc(n-start)=-data(2);
end

% 定义 inside 区域的多边形
inside_x = [polygon(1,1); polygon(2,1); polygon(3,1); polygon(4,1)];
inside_y = -[polygon(1,2); polygon(2,2); polygon(3,2); polygon(4,2)];
polyin_inside = polyshape({inside_x}, {inside_y});

% 判断每一帧是否在 inside 区域
TFin_inside = isinterior(polyin_inside, xloc, yloc);

% 获取 inside 的时间段
inside_segments = get_time_segments(TFin_inside);

% 计算 outside 的时间段
outside_segments = get_outside_segments(inside_segments, numFrames);

% 将 inside_segments 和 outside_segments 转换为 cell 类型
inside_segments_cell = num2cell(inside_segments);
outside_segments_cell = num2cell(outside_segments);

% 将类型标记添加到各自的时间段
inside_segments_with_type = [inside_segments_cell, repmat({'Inside'}, size(inside_segments, 1), 1)];
outside_segments_with_type = [outside_segments_cell, repmat({'Outside'}, size(outside_segments, 1), 1)];

% 合并 inside 和 outside 的时间段
all_segments = [inside_segments_with_type; outside_segments_with_type];

% 按时间排序
all_segments = sortrows(all_segments, 1);
% 定义输出文件名
outputFileName = 'open_field_time.txt';

% 写入到文件
fileID = fopen(outputFileName, 'w');
if fileID == -1
    error('无法打开文件 %s', outputFileName);
end

% 写入文件头
fprintf(fileID, 'Time Segments\n\n');
fprintf(fileID, 'Configuration file:\nInside i\nOutside o\n\n');
fprintf(fileID, 'S1:start end type\n\n');

% 写入时间段
for i = 1:size(all_segments, 1)
    fprintf(fileID, '%d %d %s\n', all_segments{i, 1}, all_segments{i, 2}, all_segments{i, 3});
end

% 关闭文件
fclose(fileID);
disp(['时间段已保存到 ', outputFileName]);

% 定义函数：获取连续时间段
function segments = get_time_segments(region_data)
    % 确保输入为逻辑数组
    if ~islogical(region_data)
        error('Input region_data must be a logical array.');
    end

    % 如果 region_data 全为 false，直接返回空数组
    if ~any(region_data)
        segments = [];
        return;
    end

    % 找到值为1的位置
    indices = find(region_data);

    % 计算连续时间段的起止索引
    diff_indices = diff(indices);
    breaks = [0; find(diff_indices > 1); numel(indices)];
    start_points = indices(breaks(1:end-1) + 1);
    end_points = indices(breaks(2:end));
    valid_indices = start_points ~= end_points;
    start_points = start_points(valid_indices);
    end_points = end_points(valid_indices);
    
    % 合并为时间段
    segments = [start_points, end_points];
end

% 定义函数：获取 outside 的时间段
function outside_segments = get_outside_segments(inside_segments, numFrames)
    if isempty(inside_segments)
        outside_segments = [1, numFrames]; % 如果没有 inside，整个时间段是 outside
        return;
    end

    % 计算 outside 时间段
    outside_segments = [];
    start_frame = 1;

    for i = 1:size(inside_segments, 1)
        inside_start = inside_segments(i, 1);
        inside_end = inside_segments(i, 2);

        % 添加 start_frame 到 inside_start - 1 的时间段
        if start_frame < inside_start
            outside_segments = [outside_segments; start_frame, inside_start - 1];
        end

        % 更新 start_frame 为 inside_end + 1
        start_frame = inside_end + 1;
    end

    % 添加最后一个 outside 时间段
    if start_frame <= numFrames
        outside_segments = [outside_segments; start_frame, numFrames];
    end
end

clc;clear;close all;
[Fstart, Fstop, behaviors] = inputtext('open_field_time.txt');
SFstart = Fstart;
SFstop = Fstop;
Sbehaviors = behaviors;

fig = figure(1); hold on;

% outside
outid = strfind_part(Sbehaviors, {'Outside'});
hline1 = line(NaN, NaN, 'LineWidth', 5, 'LineStyle', '-', 'Color', 'r'); % Create a line object for 'outside'
for i = 1:length(outid)
    rectangle('Position', [(SFstart(outid(i))) / 25, 0, (SFstop(outid(i)) - SFstart(outid(i))) / 25, 0.2], ...
        'FaceColor', 'r', 'EdgeColor', 'none');
end

% inside
inid = strfind_part(Sbehaviors, {'Inside'});
hline2 = line(NaN, NaN, 'LineWidth', 5, 'LineStyle', '-', 'Color', 'b'); % Create a line object for 'inside'
for i = 1:length(inid)
    rectangle('Position', [(SFstart(inid(i))) / 25, 0, (SFstop(inid(i)) - SFstart(inid(i))) / 25, 0.2], ...
        'FaceColor', 'b', 'EdgeColor', 'none');
end


% Add legends
legend([hline1, hline2], {'Outside', 'Inside'})
rect = [0.943, 0.739, 0, 0];
set(legend, 'Position', rect)

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.5, 0.8, 0.2])

set(gca,'ytick',[])
box on

ylabel(''); xlabel('');
xlim([0 600])
disp('图像已生成，根据时间段文件成功绘制 Inside 和 Outside 区域。');