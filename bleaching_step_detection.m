
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Photobleaching Step Detection
%     Copyright (C) 2014
%     Venkatramanan Krishnamani, Rahul Chadda & ...
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   bleaching_step_detection(dat,fig_num)
% - modified from heaviside_step_detection_v1
%   to process bleaching trace (Jan 2012)
%
%   detect bleaching steps in intensity trace by fitting a sliding
%   Heaviside step funtion.
%
%   The output data matrix has the following format:
%   steps(1,:) = step time.
%   steps(2,:) = step size.
%   steps(3,:) = baseline.
%
%   The input data contain both displacement and time points:
%    dat == displacement and time data.
%           dat(1,:) = displacement data
%           dat(2,:) = time information
%   fig_num == figure number; 0 for no display
%

function rv=bleaching_step_detection(dat,fig_num,aoi)

% display raw data
% if fig_num>0
%     figure(fig_num);
%     %plot(dat(2,:),dat(1,:),'k.','markersize',5); hold on
%     plot(dat(2,:),dat(1,:),'k');
%     %pause(0.1);   %for display purpose
% end

%default scan window size
winsize = 10;                                                               %10 frames; need to consider multiple steps within a window
%dwell rejection
f_reject = 2;                                                               %a step has to last more than 2 frames

%set bleaching step to be negative
forward = -1;
%use 3 step size initial guesses to scan for different step sizes
gstep = forward*[0.25 0.5 0.75]*(max(dat(1,:))-min(dat(1,:)));

% set initial window and values
inarg = [gstep(1) mean(dat(1,1:5))];                                        %[step_size_guess  baseline_estimate]
rawdat = dat(:,1:winsize);                                                  %data window for step detection
tindx = 1;                                                                  %time point index for scanning data
winref = 1;                                                                 %current start reference point of a window
cntindx = 1;                                                                %count number for scanned points in the current winsize window
tflag = 1;                                                                  %flag for updating chi_sq_min
step_num = 0;
steps = [];
%residual noise level for step detection
noise_level = std( dat(1,:)-filter_median(dat(1,:),3) )^2;
%==========================================================================
%look for steps by sliding tstep within a window.  If no step is found
%within the current window, slide into the next window while keeping the
%current window.  If a step is found, reset the initial values and window
%size to start another search immediately after the step that was just
%detected.  continue searching to the end of data set.
%==========================================================================
while tindx<=length(dat(2,:))
    tstep=dat(2,tindx);
    %--- define Heaviside fitting function ---
    chi2_heaviside=inline(['sum(([' num2str(rawdat(1,:)) ']-inarg(1)*([' ...
        num2str(rawdat(2,:)) ']>' num2str(tstep) ')-inarg(2)).^2)'],'inarg');

    %try different step guesses
    %gstep(1)
    inarg(1)=gstep(1);
    outarg=fminsearch(chi2_heaviside,inarg, optimset('MaxFunEvals',1e20,'MaxIter',1e10));
    chi_sq1=sum((rawdat(1,:)-outarg(1)*(rawdat(2,:)>tstep)-outarg(2)).^2);
    %gstep(2)
    inarg(1)=gstep(2);
    outarg=fminsearch(chi2_heaviside,inarg, optimset('MaxFunEvals',1e20,'MaxIter',1e10));
    chi_sq2=sum((rawdat(1,:)-outarg(1)*(rawdat(2,:)>tstep)-outarg(2)).^2);
    %gstep(3)
    inarg(1)=gstep(3);
    outarg=fminsearch(chi2_heaviside,inarg, optimset('MaxFunEvals',1e20,'MaxIter',1e10));
    chi_sq3=sum((rawdat(1,:)-outarg(1)*(rawdat(2,:)>tstep)-outarg(2)).^2);

    chi_sq=min([chi_sq1 chi_sq2 chi_sq3]);
    dat_num = length(rawdat(1,:));                                          %number of points used in calculating
    %chi square.  This is used to normalize the global noise_level.

    if tflag==1 ;                                                           %assign initial min_chi_sq to a new scan window
        min_chi_sq=chi_sq;
    end

    if chi_sq<min_chi_sq || tflag==1   ;                                    %no step is detected
        inarg=outarg;                                                       %update min_chi_sq
        min_chi_sq=chi_sq;
        cntindx=cntindx+1;                                                  %update scan index
        tflag=2;                                                            %update window flag for step scanning
        if cntindx==winsize ;                                               %resize window when scan index
            tflag=1;                                                        %reaches the end of scan window
            cntindx=1;
            if tindx+winsize-1>=length(dat(2,:));
                rawdat=dat(:,winref:end);
            else
                rawdat=dat(:,winref:tindx+winsize-1);
            end
        end
    %step dtection criteria are set here:
    %(1) step has to last more than 2 frames
    %(2) chi_sq has to increase by more than a set threshold (noise_level)
    %    above the min_chi_sq (the lowest chi_sq measured so far)
    %just passed/detected a step
    elseif chi_sq > (min_chi_sq+noise_level*dat_num) & ...                  %chi_sq increase significantly
            cntindx > f_reject      ;                                       %reject possible steps with 2 or
        %less frame dwell time

        step_num=step_num+1;
        if step_num==1     ;                                                %record first step
            dstep=outarg(1,1);
            baseline=mean(dat(1,1:tindx-2));                                %refine the first baseline
        else
            baseline=mean(dat(1,(sum((dat(2,:)<steps(1,step_num-1)))+2):tindx-2));
            steps(2,step_num-1)=baseline-steps(3,step_num-1);               %refine previous step size
        end
        inarg=[dstep baseline+dstep];                                       %set initial guesses for the next round

        steps=[steps [mean(dat(2,tindx+[-1 0]));dstep;baseline]];           %record a step detected

        tflag=1;                                                            %reset window flag for a new window
        winref=tindx;
        cntindx=1;                                                          %reset scan index
        if tindx+winsize-1>=length(dat(2,:));                               %reset scan window
            rawdat=dat(:,tindx:length(dat(2,:)));
        else
            rawdat=dat(:,tindx:tindx+winsize-1);
        end
        if fig_num>0                                                        % display detected step time
            % disp(['      ' num2str(mean(dat(2,tindx+[-1 0])))]);
        end

    else                                                                    %no step is detected
        inarg=outarg;                                                       %no change in min_chi_sq
        cntindx=cntindx+1;
        tflag=2;
        if cntindx==winsize ;
            tflag=1;
            cntindx=1;
            if tindx+winsize-1>=length(dat(2,:))
                rawdat=dat(:,winref:length(dat(2,:)));
            else
                rawdat=dat(:,winref:tindx+winsize-1);
            end
        end
    end
    tindx=tindx+1;                                                          %advance to the next frame
    %within the while loop
end

%fprintf('Step Number: %d, Frame Number: %d', step_num, tindx);
if step_num > 0
    %refine the last step size
    steps(2,step_num)=mean(dat(1,dat(2,:)>steps(1,step_num)))-steps(3,step_num);
    % filter out the steps that are increasing in intensity (photobleaching
    % is strictly decreases in intensity)
    filter_matrix = steps(2,:) < 0;
    filter_matrix = repmat(filter_matrix, [size(steps(:,1)), 1]);
    steps = reshape(steps(logical(filter_matrix)),[size(steps(:,1)), sum(filter_matrix(1,:))]);
    step_num = length(steps(1,:));
end

if step_num > 0
    %remove small steps that are smaller than 1x standard deviation of
    %noise level in the horizontal segments
    x_range = [0 steps(1,:) dat(2,end)];
    data_std = NaN(1,length(x_range)-1);
    for index = 1:length(x_range)-1
        data_std(1,index) = std(dat(1,ceil(x_range(index))+1:floor(x_range(index+1))));
    end
    noise = mean2(data_std);
    filter_matrix = steps(2,:) < -1*noise;
    filter_matrix = repmat(filter_matrix, [size(steps(:,1)), 1]);
    steps = reshape(steps(logical(filter_matrix)),[size(steps(:,1)), sum(filter_matrix(1,:))]);
    %update step size to account for deletion of small steps
    for k = 1:length(steps(3,:))-1
        steps(2,k) = steps(3,k) - steps(3,k+1);
    end
    step_num = length(steps(1,:));
end

if step_num > 1
    %remove blinking steps
    logical_filter = ones(size(steps(2,:)));
    for k = 1:length(steps(2,:))-1
        if (steps(3,k)+steps(2,k)) ~= steps(3,k+1)
            logical_filter(k) = 0;
        end
    end
    logical_filter = repmat(logical_filter, [size(steps(:,1)), 1]);
    steps = reshape(steps(logical(logical_filter)),[size(steps(:,1)), sum(logical_filter(1,:))]);
end

if step_num > 0
    step_time = steps(1,:);
    step_size = steps(2,:);
    step_baseline = steps(3,:);
    step_num = length(steps(1,:));
end

%plot the detected steps and display step data
if step_num>0 && fig_num>0 ;
    line([dat(2,1) steps(1,1)],steps(3,1)*ones(1,2),'linewidth',2);
    for indx=1:step_num ;
        line(steps(1,indx)*ones(1,2),[steps(3,indx) sum(steps(2:3,indx))],'linewidth',2);
        if indx==step_num ;
            line([steps(1,indx) dat(2,end)],sum(steps(2:3,indx))*ones(1,2),'linewidth',2);
        else
            line([steps(1,indx) steps(1,indx+1)],steps(3,indx+1)*ones(1,2),'linewidth',2);
        end
    end
    % disp(steps);
end
disp(['Total number of steps detected for AOI-' num2str(aoi) ' = ' num2str(step_num)]);
%==== return detected steps ===========
step_details = {};
if step_num>0
    step_details = {step_time,step_size,step_baseline};
end
rv={step_num,step_details};
% steps(1,:)=step time.
% steps(2,:)=step size.
% steps(3,:)=baseline.
%======================================




