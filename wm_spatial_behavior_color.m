% Working Memory PFC columnar imaging with spatial task
% Samples at different directions are shown at the same time with different
% colors
% By Yuan    @ 20230830
% By Yuan    @ 20231227
% By Yuan    @ 20231229

%% 
resDir = [CurrDir '\Results\behavior\' SubjID '\'];
if ~isdir(resDir)
    mkdir(resDir);
end

if exist([CurrDir '\Results\behavior\' SubjID '\' SubjID '_Sess' num2str(SessID) '_SpatialTask_color_run' num2str(RunID) '.mat'],'file')
    ShowCursor;
    Screen('CloseAll');
    reset_test_gamma;
    warning on;
    error('This run number has been tested, please enter a new run num!');
end

results = zeros(Param.DisBehav.TrialNum,11);
timePoints = zeros(Param.DisBehav.TrialNum,10);
trial_index = randperm(Param.DisBehav.TrialNum);
trial_index = mod(trial_index,Param.Discri.DirectionNum)+1;

%% Create sequence 
% To minimise sampling bias, a uniformly distributed sampling sequence is
% created. Column1 = stimu1, Column2 = stimu2, Column(end) = cue.
if CounBalance == 1
    if RunID == 1
        squmat = zeros(Param.DisBehav.TrialNum * Behav_Run_Num,Param.SpatialDot.DiskNum+1);
        All_Comb = nchoosek(1:length(Param.Discri.Directions),Param.SpatialDot.DiskNum);
        Comb_Num = size(All_Comb,1);
        Mini_Num = floor((Param.DisBehav.TrialNum * Behav_Run_Num) / (Comb_Num * Param.SpatialDot.DiskNum));

        squmat(1:Param.SpatialDot.DiskNum*Mini_Num*Comb_Num,1:end-1) = repmat(All_Comb,Param.SpatialDot.DiskNum*Mini_Num,1);
        squmat(1:Param.SpatialDot.DiskNum*Mini_Num*Comb_Num,end) = reshape(repmat(1:Param.SpatialDot.DiskNum,Comb_Num,Mini_Num),[],1);

        remainder = mod(Param.DisBehav.TrialNum * Behav_Run_Num, Comb_Num * Param.SpatialDot.DiskNum);
        squmat(Param.SpatialDot.DiskNum*Mini_Num*Comb_Num+1:end,1:end) = squmat(randsample(Comb_Num * Param.SpatialDot.DiskNum,remainder),1:end);
        randsort = randperm(size(squmat,1));
        squmat = squmat(randsort,:,:);
        squmat = squmat(randsort,:,:);

        save([resDir SubjID '_Sess' num2str(SessID) '_Squence.mat'],'squmat')
    else
        load([resDir SubjID '_Sess' num2str(SessID) '_Squence.mat'])
    end
end
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
% 3- ITI                    4- Sample duration
% 5- ISI                    6- Cue duration
% 7- Delay duration         8- Test duration
% 9- reaction time          10- trial duration

%% Main experiment
%% initialize eye tracker
    mainfilename = [SubjID '_' num2str(SessID) '_' num2str(RunID)];
    dummymode = 0; 
    
    el=EyelinkInitDefaults(wnd);

    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end

    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs);

    % make sure that we get event data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');

    % open file to record data to
    edfFile=[mainfilename '.edf'];
    Eyelink('Openfile', edfFile);

    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    % STEP 6
    % do a final check of calibration using driftcorrection
    success=EyelinkDoDriftCorrection(el);
    if success~=1
        cleanup;
        return;
    end

    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR; % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end


%% Staircase settings
UD = PAL_AMUD_setupUD('up',Param.Staircase.Up,'down',Param.Staircase.Down);
UD = PAL_AMUD_setupUD(UD,'StepSizeDown',Param.Staircase.StepSizeDown,'StepSizeUp',Param.Staircase.StepSizeUp, ...
    'stopcriterion', Param.Staircase.StopCriterion,'xMax',Param.Staircase.xMax,'xMin',Param.Staircase.xMin,'truncate','yes');
UD = PAL_AMUD_setupUD(UD,'startvalue', Param.Staircase.AngleDelta,'stoprule',Param.Staircase.StopRule);

%% Display hint
curr_textBounds = Screen('TextBounds', wnd,'Press Space to start');
DrawFormattedText(wnd,'Press Space to start', ...
    Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-curr_textBounds(3)/2, ...
    Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-curr_textBounds(4)/2, ...
    white);
Screen('Flip',wnd);
while true
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(Param.Keys.Space)
        break;
    elseif keyCode(Param.Keys.EscPress)
        abort;
    end
end

%% Spatial task
while (~UD.stop)
    trial_i = size(UD.response,2)+1;
    results(trial_i,1) = trial_i;
    results(trial_i,2) = Param.Stimuli.LocationUsed;
   
    % task diff
    results(trial_i,6) = UD.xCurrent;
    jitter_temp = sign(rand-0.5);
    if jitter_temp == 0
        jitter_temp = 1;
    end
    curr_jitter = jitter_temp * results(trial_i,6);


    % determine the two locations
    if CounBalance == 1
       results(trial_i,3) = squmat((RunID-1)*Param.DisBehav.TrialNum+trial_i,1);
       results(trial_i,4) = squmat((RunID-1)*Param.DisBehav.TrialNum+trial_i,2);
       results(trial_i,5) = squmat((RunID-1)*Param.DisBehav.TrialNum+trial_i,3);
    else
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
      end         
    % task start time
    trial_onset = GetSecs;
    timePoints(trial_i,1) = trial_onset;

    % start recoding
    Eyelink('startrecording');
    Eyelink('Message','Trial %d Begin',trial_i);


    % draw prefixation
    Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
    Screen('DrawLines', wnd, Param.Fixation.CrossLoc2, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
    vbl = Screen('Flip',wnd);
    timePoints(trial_i,2) = vbl - timePoints(trial_i,1);

    %% base location
    curr_loc = zeros(3,Param.SpatialDot.DiskNum); % sti 1 st2 & test sti
    results(trial_i,10) = Param.Discri.Directions(results(trial_i,3)) + (rand - 0.5) * 2 *Param.SpatialDot.AngleJitter;
    results(trial_i,11) = Param.Discri.Directions(results(trial_i,4)) + (rand - 0.5) * 2 *Param.SpatialDot.AngleJitter;
    if results(trial_i,5) == 1
        results(trial_i,7) = results(trial_i,10) + curr_jitter;
    else
        results(trial_i,7) = results(trial_i,11) + curr_jitter;
    end
    
    curr_loc(1,1) = Param.SpatialDot.OuterRadius * cos(results(trial_i,10)/180*pi)+Param.Stimuli.Locations(3,1);
    curr_loc(1,2) = Param.SpatialDot.OuterRadius * sin(results(trial_i,10)/180*pi)+Param.Stimuli.Locations(3,2);
    curr_loc(2,1) = Param.SpatialDot.OuterRadius * cos(results(trial_i,11)/180*pi)+Param.Stimuli.Locations(3,1);
    curr_loc(2,2) = Param.SpatialDot.OuterRadius * sin(results(trial_i,11)/180*pi)+Param.Stimuli.Locations(3,2);
    curr_loc(3,1) = Param.SpatialDot.OuterRadius * cos(results(trial_i,7)/180*pi)+Param.Stimuli.Locations(3,1);
    curr_loc(3,2) = Param.SpatialDot.OuterRadius * sin(results(trial_i,7)/180*pi)+Param.Stimuli.Locations(3,2);
             
   %% dot color
    curr_color_temp = randperm(Param.Discri.DirectionNum,Param.SpatialDot.DiskNum);
    curr_color(1,:) = Param.SpatialDot.DiskColor(curr_color_temp(1),:);
    curr_color(2,:) = Param.SpatialDot.DiskColor(curr_color_temp(2),:);
    if results(trial_i,5) == 1
        curr_color(3,:) = curr_color(1,:);  % cue color
    else
        curr_color(3,:) = curr_color(2,:);
    end

    %% Display Sample
    for i_dir = 1:Param.SpatialDot.DiskNum
        Screen('FillOval',wnd,curr_color(i_dir,:),[curr_loc(i_dir,1)-Param.SpatialDot.DotSize, curr_loc(i_dir,2)-Param.SpatialDot.DotSize,curr_loc(i_dir,1)+Param.SpatialDot.DotSize,curr_loc(i_dir,2)+Param.SpatialDot.DotSize]);
    end

    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.Prefix);  %-Slack
    % save current time duration into results
    timePoints(trial_i,3) = vbl - sum(timePoints(trial_i,1:2));

    %% Display ISI
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.durColor); % -Slack
    timePoints(trial_i,4) = vbl - sum(timePoints(trial_i,1:3));

    %% display cue
    Screen('FillOval',wnd,curr_color(3,:),Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.ISIColor); %-Slack
    timePoints(trial_i,5) = vbl - sum(timePoints(trial_i,1:4));

    %% delay
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.CueColor); % -Slack
    timePoints(trial_i,6) = vbl - sum(timePoints(trial_i,1:5));

    %% test
    Screen('FillOval',wnd,curr_color(3,:),[curr_loc(3,1)-Param.SpatialDot.DotSize, curr_loc(3,2)-Param.SpatialDot.DotSize,curr_loc(3,1)+Param.SpatialDot.DotSize,curr_loc(3,2)+Param.SpatialDot.DotSize]);
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+Param.Trial.Delay); %-Slack
    timePoints(trial_i,7) = vbl - sum(timePoints(trial_i,1:6));

    %% response
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+ Param.Trial.testColor); %-Slack
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
    UD = PAL_AMUD_updateUD(UD, results(trial_i,9)); % update UD structure

    while (GetSecs - timePoints(trial_i,1) < Param.Trial.Duration_Beh)
        timePoints(trial_i,10) = GetSecs - timePoints(trial_i,1);
    end
    % stop recoding
    Eyelink('Message','Trial %d End',trial_i);
    Eyelink('stoprecording');

end

Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
Screen('Flip',wnd);

%% compute accuracy
subjAccu = sum(results(:,9))./Param.DisBehav.TrialNum;
disp(' ');
disp(['Accuracy: ' num2str(subjAccu)]);
disp(' ');

%% save data
threshold_value = PAL_AMUD_analyzeUD(UD, 'reversals', max(UD.reversal)-Param.Staircase.ReversalsUsed);
cd(resDir);
resName = [SubjID '_Sess' num2str(SessID) '_SpatialTask_color_run' num2str(RunID) '.mat'];
save(resName,'results','timePoints','UD','threshold_value','subjAccu','Param');
cd(CurrDir);
%% download eyelink data file
Eyelink('CloseFile');
% download data file
try
    fprintf('Receiving data file ''%s''\n', edfFile);
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd);
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', edfFile );
    rdf;
end

%figure(1);
%analEdf_fra([mainfilename '.edf'],Param);
%hold on;

figure(2);
edf_used=Edf2Mat([mainfilename '.edf'],1);
fix_num = size(edf_used.Events.Efix.start,2);
scatter(edf_used.Events.Efix.posX,edf_used.Events.Efix.posY);
hold on;


%% plot
figure(3);
end_trial = size(UD.x,2);
task_diff_temp = UD.x;

plot(1:end_trial,task_diff_temp(1:end_trial));
axis([0 Param.Staircase.MaxTrial 0 15]);
%%
warning on;
reset_test_gamma;
ShowCursor;
Screen('CloseAll');

delete *.asv
