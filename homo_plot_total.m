function create_behavior_plots_from_folder(folder_path)
    % Get a list of all .txt files in the specified folder
    txt_files = dir(fullfile(folder_path, '*.txt'));
    
    % Create a figure to hold all the plots (arranged vertically)
    fig = figure;
    hold on;
    
    % Initialize a variable to control the vertical offset for each plot
    offset = 0; 
    
    % Loop through each file in the folder
    for f = 1:length(txt_files)
        % Read behavior data from the current txt file
        file_path = fullfile(txt_files(f).folder, txt_files(f).name);
        [Fstart, Fstop, behaviors] = inputtext(file_path);
        
        intro_id = strfind_part(behaviors, {'introduce'});
        rmv_id = strfind_part(behaviors, {'remove'});
        SFstart = Fstart(intro_id:rmv_id-1);
        SFstop = Fstop(intro_id:rmv_id-1);
        Sbehaviors = behaviors(intro_id:rmv_id-1);
        
        % Plot each behavior in the file
        % Attack
        Attackid = strfind_part(Sbehaviors, {'attack'});
        for i = 1:length(Attackid)
            rectangle('Position', [(SFstart(Attackid(i)) - Fstop(intro_id)) / 25, offset, ...
                (SFstop(Attackid(i)) - SFstart(Attackid(i))) / 25, 0.25], ...
                'FaceColor', 'r', 'EdgeColor', 'none');
        end
        
        % Sniff
        Sniffid = strfind_part(Sbehaviors, {'sniff'});
        for i = 1:length(Sniffid)
            rectangle('Position', [(SFstart(Sniffid(i)) - Fstop(intro_id)) / 25, offset, ...
                (SFstop(Sniffid(i)) - SFstart(Sniffid(i))) / 25, 0.25], ...
                'FaceColor', 'c', 'EdgeColor', 'none');
        end
        
        % Approach
        Approachid = strfind_part(Sbehaviors, {'approach'});
        for i = 1:length(Approachid)
            rectangle('Position', [(SFstart(Approachid(i)) - Fstop(intro_id)) / 25, offset, ...
                (SFstop(Approachid(i)) - SFstart(Approachid(i))) / 25, 0.25], ...
                'FaceColor', 'c', 'EdgeColor', 'none');
        end
        
        % Pre_attack
        Pre_attackid = strfind_part(Sbehaviors, {'pre_attack'});
        for i = 1:length(Pre_attackid)
            rectangle('Position', [(SFstart(Pre_attackid(i)) - Fstop(intro_id)) / 25, offset, ...
                (SFstop(Pre_attackid(i)) - SFstart(Pre_attackid(i))) / 25, 0.25], ...
                'FaceColor', 'c', 'EdgeColor', 'none');
        end
        
        % Mount
        Mountid = strfind_part(Sbehaviors, {'mount'});
        for i = 1:length(Mountid)
            rectangle('Position', [(SFstart(Mountid(i)) - Fstop(intro_id)) / 25, offset, ...
                (SFstop(Mountid(i)) - SFstart(Mountid(i))) / 25, 0.25], ...
                'FaceColor', 'c', 'EdgeColor', 'none');
        end
        
        % Update the offset for the next plot to appear below the current one
        offset = offset + 0.3;  
        
    end
    
    % Adjust the figure size
    xlim([0 600])
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.8, 0.4]);
    set(gca,'ytick',[])
    box on
    ylabel(''); xlabel('');
    % Save the figure as a .tif image
    saveas(fig, fullfile(folder_path, 'homo_BCattack_plots_combined.tif'));
end

create_behavior_plots_from_folder("E:\Mei Lab\Data\行为学\male-male aggressive behavior\dt\Total\Sert-cre")