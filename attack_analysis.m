%% male-male aggressive behavior
clc; clear;
[Fstart, Fstop, behaviors] = inputtext("E:\Mei Lab\Data\行为学\male-male aggressive behavior\dt\20250313\WZK0024\dt_BCattack_homo_wzk0024.txt");

% 提取 introduce 和 remove 阶段之间的行为数据
intro_id = strfind_part(behaviors, {'introduce'});
rmv_id = strfind_part(behaviors, {'remove'});
SFstart = Fstart(intro_id:rmv_id-1);
SFstop = Fstop(intro_id:rmv_id-1);
Sbehaviors = behaviors(intro_id:rmv_id-1);
frate=24.9456;

% 分析攻击行为（attack）
Attackid = strfind_part(Sbehaviors, {'attack'});
Attack_start = SFstart(Attackid); % 攻击行为的开始时间
Attack_stop = SFstop(Attackid);  % 攻击行为的结束时间

% 计算攻击行为的指标
if ~isempty(Attackid)
    Attack_durations = sum(Attack_stop - Attack_start); % 所有攻击行为持续时间之和
    Attack_count = length(Attackid);                   % 攻击行为的发生次数
    First_attack_time = Attack_start(1) - SFstart(1);  % 第一次攻击相对于 introduce 的时间
else
    Attack_durations = 0;
    Attack_count = 0;
    First_attack_time = NaN; % 如果没有攻击行为，设为 NaN
end

% 将结果保存为文本文件
result_file = fullfile("E:\Mei Lab\Data\行为学\male-male aggressive behavior\dt\20250313\WZK0024", 'dt_BCattack_wzk0024_analysis.txt');
fileID = fopen(result_file, 'w');
fprintf(fileID, '攻击行为分析结果：\n');
fprintf(fileID, '攻击发生次数：%d\n', Attack_count);
fprintf(fileID, '攻击行为总持续时间（秒）：%.2f\n', Attack_durations / frate); % 转换为秒
if Attack_count > 0
    fprintf(fileID, '第一次攻击发生时间（秒）：%.2f\n', First_attack_time / frate); % 转换为秒
else
    fprintf(fileID, '没有检测到攻击行为。\n');
end
fclose(fileID);

disp(['分析结果已保存到文件: ', result_file]);
