%% Three chamber test
clc; clear;
[Fstart, Fstop, behaviors] = inputtext("F:\Mei Lab\Data\行为学\three chamber test\CNO\20241224\WZK0011\CNO_chamber_wzk0011.txt");

% 提取 introduce 和 remove 阶段之间的行为数据
intro_id = strfind_part(behaviors, {'introduce'});
rmv_id = strfind_part(behaviors, {'remove'});
SFstart = Fstart(intro_id:rmv_id-1);
SFstop = Fstop(intro_id:rmv_id-1);
Sbehaviors = behaviors(intro_id:rmv_id-1);
frate=24.9456;

maleid = strfind_part(Sbehaviors, {'male_side'});
male_start = SFstart(maleid); 
male_stop = SFstop(maleid);  
male_time = sum(male_stop - male_start); 

femaleid = strfind_part(Sbehaviors, {'female_side'});
female_start = SFstart(femaleid); 
female_stop = SFstop(femaleid);  
female_time = sum(female_stop - female_start); 

clearingid = strfind_part(Sbehaviors, {'other'});
clearing_start = SFstart(clearingid); 
clearing_stop = SFstop(clearingid);  
clearing_time = sum(clearing_stop - clearing_start); 

total_time = male_time + clearing_time + female_time;
r_male = male_time / total_time * 900;
r_clearing = clearing_time / total_time * 900;
r_female = female_time / total_time * 900;

figure;
pie([male_time, clearing_time, female_time]);
legend(['Male ' num2str(r_male)], ['Clearing ' num2str(r_clearing)], ['Female ' num2str(r_female)], 'Location', 'northeastoutside');
saveas(gcf, 'region_time_distribution.tif');