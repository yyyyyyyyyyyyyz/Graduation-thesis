%% three chamber test (interact)
clc;clear;
[Fstart, Fstop, behaviors] = inputtext("F:\Mei Lab\Data\行为学\three chamber test\CNO\20241114\WZK0003\CNO_chamber_wzk0003_interaction.txt");
intro_id = strfind_part(behaviors, {'introduce'});
rmv_id = strfind_part(behaviors, {'remove'});
SFstart = Fstart(intro_id:rmv_id-1);
SFstop = Fstop(intro_id:rmv_id-1);
Sbehaviors = behaviors(intro_id:rmv_id-1);

fig = figure(1); hold on;

% Male interaction
maleid = strfind_part(Sbehaviors, {'male_interact'});
hline1 = line(NaN,NaN,'LineWidth',5,'LineStyle','-','Color','b'); % Create a line object for 'male'
for i = 1:length(maleid)
    rectangle('Position', [(SFstart(maleid(i))-Fstop(intro_id))/25 0 (SFstop(maleid(i))-SFstart(maleid(i)))/25 0.2], 'FaceColor', 'b', 'EdgeColor', 'none')
end

% Female interaction
femaleid = strfind_part(Sbehaviors, {'female_interact'});
hline2 = line(NaN,NaN,'LineWidth',5,'LineStyle','-','Color','c'); % Create a line object for 'female'
for i = 1:length(femaleid)
    rectangle('Position', [(SFstart(femaleid(i))-Fstop(intro_id))/25 0 (SFstop(femaleid(i))-SFstart(femaleid(i)))/25 0.2], 'FaceColor', 'c', 'EdgeColor', 'none')
end



% Add legends
legend([hline1, hline2], {'male', 'female'})
rect = [0.943, 0.739, 0, 0];
set(legend, 'Position', rect)

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.5, 0.8, 0.2])

set(gca,'ytick',[])
box on

ylabel(''); xlabel('');
xlim([0 600])

saveas(fig, fullfile("F:\Mei Lab\Data\行为学\three chamber test\CNO\20241114\WZK0003\", ('CNO_chamber_wzk0003_interaction.tif')));