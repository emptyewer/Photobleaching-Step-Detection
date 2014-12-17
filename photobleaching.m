clear all;
path = textread('/home/venky/SMExperiments/software/step_detection/filelist.txt', '%s');
for k = 1:length(path)
    load (path{k},'-mat');
    [pathstr,name,ext] = fileparts(path{k});
    disp(['*** Calculating steps for AOIs in fileprefix ' name ' ***']);
    number_of_aois = length(aoifits.aoiinfo2);
    number_of_frames = length(aoifits.data)/length(aoifits.aoiinfo2);
    trajectories = zeros(number_of_aois, number_of_frames);
    time_data = zeros(number_of_aois, number_of_frames);
    loop_count = 1;
    value = 1;
    for i = 1:length(aoifits.data)
        trajectories(i) = aoifits.data(i,8) - aoifits.BackgroundData(i,8);
        if loop_count > number_of_aois
            loop_count = 1;
            value = value  + 1;
        end
        time_data(i) = value;
        loop_count = loop_count + 1;
    end
    tic
    grey = [0.5 0.5 0.5];
    steps = {};
    for j = 1:number_of_aois
        input_data = zeros(2,number_of_frames);
        input_data(1,:) = trajectories(j,:);
        input_data(2,:) = time_data(j,:);
        name_of_trajectory = strcat(name,'-AOI-', num2str(j));
        plot(input_data(2,:), input_data(1,:), 'Color', grey);
        title(name_of_trajectory);
        hold on;
        steps{j} = bleaching_step_detection(input_data,1, j);
        %ck_step_detection(input_data, 5, 3, 2, 1);
        pause(1.5);
        clf
    end
    num_steps = {};
    step_details = {};
    for l = 1:length(steps)
        num_steps{l} = steps{l}{1};
        step_details{l} = cell2mat(steps{l}{2});
    end
    steps_filename = strcat(pathstr, '/', name, '_stepcount.txt');
    steps_detail_filename = strcat(pathstr, '/', name, '_stepdetails.txt');
    trajectory_filename = strcat(pathstr, '/', name, '_trajectory.txt');
    dlmwrite(trajectory_filename, trajectories);
    dlmwrite(steps_filename, cell2mat(num_steps));
    dlmwrite(steps_detail_filename, cell2mat(step_details));
    toc
end