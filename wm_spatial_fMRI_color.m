% Working Memory PFC columnar imaging with spatial task
% Samples at different directions are shown at the same time with different
% colors
% By Yuan    @ 20230426
% By Yinghua @ 20230518
% By Yuan    @ 20230905
% By Yuan    @ 20231223

if exist([CurrDir '\Results\fMRI\' SubjID '\' SubjID '_Sess' num2str(SessID) '_SpatialTask_color_run' num2str(RunID) '.mat'],'file')
    ShowCursor;
    Screen('CloseAll');
    reset_test_gamma;
    warning on;
    error('This run number has been tested, please enter a new run num!');
end

results = zeros(Param.DisfMRI.TrialNum,11);
timePoints = zeros(Param.DisfMRI.TrialNum,11);
trial_index = randperm(Param.DisfMRI.TrialNum);
trial_index = mod(trial_index,Param.Discri.DirectionNum)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Results Matrix %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1- trial number           2- visual field location
% 3- sample 1 baseline      4- sample 2 baseline
% 5- cue                    6- task_diff
% 7- test angle             8- response, 1 = left, 2 = right
% 9- acc, 1 = right, 0 = wrong 
% 10- sample 1 actual      11- sample 2 actual 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TimePoint Matrix %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1- trial onset            2- fix onset delay
% 3- Prefix duration        4- Sample duration
% 5- ISI                    6- Cue duration
% 7- Delay duration         8- Test duration
% 9- reaction time          10- ITI
% 11- trial duration
%% Main experiment
%% Display hint
curr_textBounds = Screen('TextBounds', wnd,'Task will begin soon');
DrawFormattedText(wnd,'Task will begin soon', ...
    Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-curr_textBounds(3)/2, ...
    Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-curr_textBounds(4)/2, ...
    white);
Screen('Flip',wnd);
while true
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(Param.Keys.Trigger1)
        break;
    elseif keyCode(Param.Keys.EscPress)
        abort;
    end
end

%% Dummy scans
Exp_Start = GetSecs;
Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
Screen('DrawLines', wnd, Param.Fixation.CrossLoc, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
Screen('Flip',wnd);
WaitSecs(Param.DisfMRI.Dummy);

%% Spatial task
for trial_i = 1:Param.DisfMRI.TrialNum
    results(trial_i,1) = trial_i;
    results(trial_i,2) = Param.Stimuli.LocationUsed;
    
    % task diff
    results(trial_i,6) = Curr_AngleDelta;
    jitter_temp = sign(rand-0.5);
    if jitter_temp == 0
        jitter_temp = 1;
    end
    curr_jitter = jitter_temp * results(trial_i,6);
      
    % determine the two locations
    if rand > 0.5 
        results(trial_i,3) = trial_index(trial_i);  % target location = first sample
        temp = 1:Param.Discri.DirectionNum;
        temp(results(trial_i,3)) = [];
        temp_loc = randi(Param.Discri.DirectionNum-1);
        results(trial_i,4) = temp(temp_loc);
        results(trial_i,5) = 1;
    else
        results(trial_i,4) = trial_index(trial_i);  % target location = second sample
        temp = 1:Param.Discri.DirectionNum;
        temp(results(trial_i,4)) = [];
        temp_loc = randi(Param.Discri.DirectionNum-1);
        results(trial_i,3) = temp(temp_loc);
        results(trial_i,5) = 2;
    end

    %% base location
    curr_loc = zeros(3,Param.SpatialDot.DiskNum); 
    results(trial_i,10) = Param.Discri.Directions(results(trial_i,3)) + (rand - 0.5) * 2 *Param.SpatialDot.AngleJitter;
    results(trial_i,11) = Param.Discri.Directions(results(trial_i,4)) + (rand - 0.5) * 2 *Param.SpatialDot.AngleJitter;
    if results(trial_i,5) == 1
        results(trial_i,7) = results(trial_i,10) + curr_jitter;
    else
        results(trial_i,7) = results(trial_i,11) + curr_jitter;
    end
    
    curr_loc(1,1) = Param.SpatialDot.OuterRadius * cos((results(trial_i,10)-90)/180*pi)+Param.Stimuli.Locations(3,1);
    curr_loc(1,2) = Param.SpatialDot.OuterRadius * sin((results(trial_i,10)-90)/180*pi)+Param.Stimuli.Locations(3,2);
    curr_loc(2,1) = Param.SpatialDot.OuterRadius * cos((results(trial_i,11)-90)/180*pi)+Param.Stimuli.Locations(3,1);
    curr_loc(2,2) = Param.SpatialDot.OuterRadius * sin((results(trial_i,11)-90)/180*pi)+Param.Stimuli.Locations(3,2);
    curr_loc(3,1) = Param.SpatialDot.OuterRadius * cos((results(trial_i,7)-90)/180*pi)+Param.Stimuli.Locations(3,1);
    curr_loc(3,2) = Param.SpatialDot.OuterRadius * sin((results(trial_i,7)-90)/180*pi)+Param.Stimuli.Locations(3,2);

   %% dot color
    curr_color_temp = randperm(Param.Discri.DirectionNum,Param.SpatialDot.DiskNum);
    curr_color(1,:) = Param.SpatialDot.DiskColor(curr_color_temp(1),:);
    curr_color(2,:) = Param.SpatialDot.DiskColor(curr_color_temp(2),:);
    if results(trial_i,5) == 1
        curr_color(3,:) = curr_color(1,:);  % cue color
    else
        curr_color(3,:) = curr_color(2,:);
    end

%% Go!
    % task start time
    trial_onset = GetSecs;
    timePoints(trial_i,1) = trial_onset;
    % Prefix
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc2,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd);
    % vbl = Screen('Flip',wnd,vbl+ Param.Trial.ITIColor);
    timePoints(trial_i,2) = vbl-timePoints(trial_i,1);

    %% Display SampleN
    for i_dir = 1:Param.SpatialDot.DiskNum
        % Display SampleN
        Screen('FillOval',wnd,curr_color(i_dir,:),[curr_loc(i_dir,1)-Param.SpatialDot.DotSize, curr_loc(i_dir,2)-Param.SpatialDot.DotSize,curr_loc(i_dir,1)+Param.SpatialDot.DotSize,curr_loc(i_dir,2)+Param.SpatialDot.DotSize]);
    end
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.Prefix);

    % save current time duration into results
    timePoints(trial_i,3) = vbl - sum(timePoints(trial_i,1:2));

    %% ISI
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.durColor);
    timePoints(trial_i,4) = vbl - sum(timePoints(trial_i,1:3));

    %% cue
    Screen('FillOval',wnd,curr_color(3,:),Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.ISIColor);
    timePoints(trial_i,5) = vbl - sum(timePoints(trial_i,1:4));

    %% delay
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.CueColor);
    timePoints(trial_i,6) = vbl - sum(timePoints(trial_i,1:5));

    %% test
    Screen('FillOval',wnd,curr_color(3,:),[curr_loc(3,1)-Param.SpatialDot.DotSize, curr_loc(3,2)-Param.SpatialDot.DotSize,curr_loc(3,1)+Param.SpatialDot.DotSize,curr_loc(3,2)+Param.SpatialDot.DotSize]);
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+Param.Trial.Delay);
    timePoints(trial_i,7) = vbl - sum(timePoints(trial_i,1:6));

    %% response
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+Param.Trial.testColor);
    timePoints(trial_i,8) = vbl - sum(timePoints(trial_i,1:7));

    is_true = 0;
    while (is_true == 0 && GetSecs-vbl < Param.Trial.MaxRT)
        [keyIsDown_1, RT_time, keyCode] = KbCheck;
        if keyCode(Param.Keys.Right) || keyCode(Param.Keys.two1) || keyCode(Param.Keys.two2)
            results(trial_i,8) = 2;        % response
            if jitter_temp == 1
                results(trial_i,9) = 1; % acc
            end
            timePoints(trial_i,9) = RT_time - vbl;    % reation time
            is_true = 1;
        elseif keyCode(Param.Keys.Left) || keyCode(Param.Keys.one1) || keyCode(Param.Keys.one2)
            results(trial_i,8) = 1;
            if jitter_temp == -1
                results(trial_i,9) = 1;
            end
            timePoints(trial_i,9) = RT_time - vbl;
            is_true = 1;
        elseif keyCode(Param.Keys.EscPress)
            abort;
        end
    end

    %% ITI
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('Flip',wnd);
    while (GetSecs - timePoints(trial_i,1) < Param.Trial.Duration_fMRI)
        timePoints(trial_i,11) = GetSecs - timePoints(trial_i,1);
    end
end

Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
Screen('Flip',wnd);
WaitSecs(Param.DisfMRI.Dummy); 

%% record entire duration
endOfExpmt = GetSecs;
disp(' ');
expmtDur = endOfExpmt - Exp_Start;
expmtDurMin = floor(expmtDur/60);
expmtDurSec = mod(expmtDur,60);
disp(['Cycling lasted ' num2str(expmtDurMin) ' minutes, ' num2str(expmtDurSec) ' seconds']);
disp(' ')

%% compute accuracy
Accu = sum(results(:,9))./Param.DisfMRI.TrialNum;
disp(' ');
disp(['Accuracy: ' num2str(Accu)]);
disp(' ');

%% save data
resDir = [CurrDir '\Results\fMRI\' SubjID '\'];
if ~isdir(resDir)
    mkdir(resDir);
end

cd(resDir);
resName = [SubjID '_Sess' num2str(SessID) '_spatialTask_color_run' num2str(RunID) '.mat'];
save(resName,'results','Accu','Param','Exp_Start','endOfExpmt');
cd(CurrDir);
%%
warning on;
reset_test_gamma;
ShowCursor;
Screen('CloseAll');

delete *.asv