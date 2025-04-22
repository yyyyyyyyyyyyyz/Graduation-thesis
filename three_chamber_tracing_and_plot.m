clc;clear;
seqNm={'E:\Mei Lab\Data\行为学\three chamber test\pre-dt\20250306\WZK0027\predt_3chamber_wzk0027.seq'}; %tracking video
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
    for m=1:length(Y).
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
start=500; %start frame
dur=14; % set tracing period (minutes)
YY=squeeze(Y);
frate=24.9456;

for n=start+1:start+1+dur*60*frate
data=YY{n,1};
xloc(n-start)=data(1);
yloc(n-start)=-data(2);
end

%% overlay routes and polygon
for j=1:length(polygon)
    x_poly=polygon(:,1);y_poly=-polygon(:,2);
end
figure;
plot(xloc,yloc,'r-');
xlim([-10 630])
ylim([-450 -60])
saveas(gcf,'line.tif')
%% plot heatmap
figure;
heatmapp(xloc',yloc','nbins',[100 200],'lim',{[-10 630] [-450 -60]});
h=colorbar;
set(gca, 'CLim', [0 30]);
saveas(gcf,'heatmap.tif')
%% 设置区域坐标（male、clearing 和 female 区域）
% 定义 male 区域的多边形坐标
male_x = [polygon(1,1); polygon(2,1); polygon(7,1); polygon(8,1)];
male_y = -[polygon(1,2); polygon(2,2); polygon(7,2); polygon(8,2)];
polyin_male = polyshape({male_x}, {male_y});

% 定义 clearing 区域的多边形坐标
clearing_x = [polygon(2,1); polygon(3,1); polygon(6,1); polygon(7,1)];
clearing_y = -[polygon(2,2); polygon(3,2); polygon(6,2); polygon(7,2)];
polyin_clearing = polyshape({clearing_x}, {clearing_y});

% 定义 female 区域的多边形坐标
female_x = [polygon(3,1); polygon(4,1); polygon(5,1); polygon(6,1)];
female_y = -[polygon(3,2); polygon(4,2); polygon(5,2); polygon(6,2)];
polyin_female = polyshape({female_x}, {female_y});

%% 在每个区域内进行鼠标位置的统计
% 针对 male 区域
TFin_male = isinterior(polyin_male, xloc, yloc);

% 针对 clearing 区域
TFin_clearing = isinterior(polyin_clearing, xloc, yloc);

% 针对 female 区域
TFin_female = isinterior(polyin_female, xloc, yloc);

%% 绘制区域图并保存
% 绘制 male 区域
figure;
plot(polyin_male);
title('Male Region');
xlim([-10 630]);
ylim([-450 -60]);
saveas(gcf, 'male_region.tif');

% 绘制 clearing 区域
figure;
plot(polyin_clearing);
title('Clearing Region');
xlim([-10 630]);
ylim([-450 -60]);
saveas(gcf, 'clearing_region.tif');

% 绘制 female 区域
figure;
plot(polyin_female);
title('Female Region');
xlim([-10 630]);
ylim([-450 -60]);
saveas(gcf, 'female_region.tif');

%% 在每个区域内计算停留时间比例
male_time = nnz(TFin_male(:) == 1);
clearing_time = nnz(TFin_clearing(:) == 1);
female_time = nnz(TFin_female(:) == 1);

% 计算比例（单位时间为600秒）
total_time = male_time + clearing_time + female_time;
r_male = male_time / total_time * 840;
r_clearing = clearing_time / total_time * 840;
r_female = female_time / total_time * 840;

% 绘制饼图
figure;
pie([male_time, clearing_time, female_time]);
legend(['Male ' num2str(r_male)], ['Clearing ' num2str(r_clearing)], ['Female ' num2str(r_female)], 'Location', 'northeastoutside');
saveas(gcf, 'region_time_distribution.tif');

%% 保存数据到 Excel 文件
xlswrite('distribution.xls', {'Male', 'Clearing', 'Female'}, 1, 'A1');
xlswrite('distribution.xls', [male_time, clearing_time, female_time], 1, 'A2');
xlswrite('distribution.xls', [r_male, r_clearing, r_female], 1, 'A3');