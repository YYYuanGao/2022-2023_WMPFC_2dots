%% parameters
Param = struct;

%% Basic Settings
% Param.Settings.ViewDistance   = 1430;            % mm 

Param.Settings.ViewDistance     = 600;            % 1560mm, with bitebar, editted in 24 May 2023
Param.Settings.ScrnResolution   = [0 0 1024 768]; %[0 0 1024 768];[0 0 1920 1080]
Param.Settings.SquareSize       = Param.Settings.ScrnResolution(3);             % pixels
Param.Settings.SquareLength     = 360;             % mm 
Param.Settings.PixelPerDegree   = 2*Param.Settings.ViewDistance*tan(1/2/180*pi)*Param.Settings.SquareSize/Param.Settings.SquareLength; 
Param.Settings.offset           = offset;

%% Keys for Response
Param.Keys.Space        = 32;  
Param.Keys.EscPress     = 27;
Param.Keys.Left         = 37; 
Param.Keys.Right        = 39;
Param.Keys.one1         = 49; 
Param.Keys.two1         = 50;
Param.Keys.one2         = 97; 
Param.Keys.two2         = 98;
Param.Keys.Trigger1     = 83;  % 's'    

%% Stimulus Locations
Param.Stimuli.Eccentricity   = 5; % degree
Param.Stimuli.Locations(1,:) = [Param.Settings.ScrnResolution(3)/2 - Param.Stimuli.Eccentricity * Param.Settings.PixelPerDegree , Param.Settings.ScrnResolution(4)/2] + Param.Settings.offset;
Param.Stimuli.Locations(2,:) = [Param.Settings.ScrnResolution(3)/2 + Param.Stimuli.Eccentricity * Param.Settings.PixelPerDegree , Param.Settings.ScrnResolution(4)/2] + Param.Settings.offset;
Param.Stimuli.Locations(3,:) = [Param.Settings.ScrnResolution(3)/2, Param.Settings.ScrnResolution(4)/2] + Param.Settings.offset;
Param.Stimuli.LocationsText  = {'Left','Right','Center'};
% location(1) = Left Visual Field;  location(2) = Right Visual Field;   location(3) = Center Visual Field;
Param.Stimuli.LocationUsed   = 3;

%% Parameters for Fixation
Param.Fixation.CrossColor    = [1,1,1]*255;
Param.Fixation.CrossSize     = 0.2*Param.Settings.PixelPerDegree;
Param.Fixation.CrossWidth    = 0.05*Param.Settings.PixelPerDegree;
Param.Fixation.CrossLoc      = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.Fixation.CrossSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.Fixation.CrossSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1), Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1);...
                                Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2), Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2), Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.Fixation.CrossSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.Fixation.CrossSize]; 
Param.Fixation.CrossLoc2     = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.Fixation.CrossSize*sqrt(2)/2, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.Fixation.CrossSize*sqrt(2)/2, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.Fixation.CrossSize*sqrt(2)/2, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.Fixation.CrossSize*sqrt(2)/2;...
                                     Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.Fixation.CrossSize*sqrt(2)/2, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.Fixation.CrossSize*sqrt(2)/2, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.Fixation.CrossSize*sqrt(2)/2, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.Fixation.CrossSize*sqrt(2)/2];  

Param.Fixation.OvalSize      = 0.3*Param.Settings.PixelPerDegree;
Param.Fixation.OvalLoc       = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.Fixation.OvalSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.Fixation.OvalSize,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.Fixation.OvalSize,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.Fixation.OvalSize];
Param.Fixation.OvalColor     = [0,0,0]; 
%% font size
Param.Text.Font = 'Helvetica';
Param.Text.Size = 36;
% Param.Text.Color = white;

%% Open Window
screens = Screen('Screens');
screenNumber = max(screens);	

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = round((white+black)/2);
black2 = 0.6 * black;
black3 = 0.4 * black;

Screen('Preference', 'SkipSyncTests', 1);
wnd = Screen('OpenWindow',screenNumber,gray,Param.Settings.ScrnResolution); 
Screen('BlendFunction', wnd, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

FrameRate = Screen('FrameRate',wnd);
NominalFrameRate = Screen('NominalFrameRate',wnd); 
RefreshDur = Screen('GetFlipInterval',wnd);
Slack = RefreshDur / 2;

Screen('TextFont', wnd, Param.Text.Font);
Screen('TextSize', wnd, Param.Text.Size);

%% Parameters for RDK
Param.RDK.DotNum     = 400;
Param.RDK.DotSize    = 6; 
%Param.RDK.Direction  = 360-120;   % 0=Rihgt 90=down 180=left 270=up
Param.RDK.Speed      = 8;         % Watanabe 14.2  %点运动速度，用于控制实验难度
Param.RDK.Coherence  = 1;         %0-1

Param.RDK.OuterRadius= 5*Param.Settings.PixelPerDegree;         % radius
Param.RDK.InnerRadius= 0.5*Param.Settings.PixelPerDegree;       % radius
Param.RDK.Duration   = 0.4;                                     % s
Param.RDK.testDuration   = 1.2;                                 % s
Param.RDK.FramesPerMove = 1;                                    % 每XX个frame更新点的位置
Param.RDK.NumFrames  = Param.RDK.Duration*NominalFrameRate/Param.RDK.FramesPerMove;         %注意：这里必须是整数
Param.RDK.StepPerMove   = Param.RDK.FramesPerMove/NominalFrameRate*Param.RDK.Speed*Param.Settings.PixelPerDegree; %移动pixel数
Param.RDK.OvalSize      = 5*Param.Settings.PixelPerDegree;
Param.RDK.OvalLoc       = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.RDK.OvalSize, ...
                           Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.RDK.OvalSize, ...
                           Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.RDK.OvalSize, ...
                           Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.RDK.OvalSize];

%% Parameters for Trials
Param.Trial.TR = 2.5;
Param.Trial.Duration_fMRI = 7 * Param.Trial.TR; % 17.5s
Param.Trial.Duration_Beh  = 12 * Param.Trial.TR; % 30s

Param.Trial.ISI = 0.6; 
Param.Trial.Cue = 1.2;

% for more than 2 sample cases
Param.Trial.ISI3 = 0.5; 
Param.Trial.Cue3 = 0.9;
Param.Trial.ISI4 = 0.4; 
Param.Trial.Cue4 = 1;
Param.Trial.ISI5 = 0.3; 
Param.Trial.Cue5 = 1;
%==============================
% for color sample cases 
Param.Trial.Prefix = 0.5;
Param.Trial.durColor = 0.5;
Param.Trial.ISIColor = 1; 
Param.Trial.CueColor = 0.5;
Param.Trial.testColor= 0.5;

Param.Trial.Delay  = 5*Param.Trial.TR;  % 11.4
Param.Trial.ITIColor = 5*Param.Trial.TR; 

Param.Trial.MaxRT  = 2;

%% Discrimination
Param.Discri.Directions   = [15,75,135,195,255,315]; % 6 directions
Param.Discri.DirectionNum = length(Param.Discri.Directions);
Param.Discri.StiLocation  = 3;
Param.Discri.Jitter       = 10;

%% fMRI 
Param.DisfMRI.TrialNum     = 18;
Param.DisfMRI.AngleDelta   = Curr_AngleDelta;
Param.DisfMRI.Dummy        = 2*Param.Trial.TR;

%% Behaviour 
Param.DisBehav.TrialNum     = 36;
Param.DisBehav.minirun      = 24;
Param.DisBehav.AngleDelta   = Curr_AngleDelta;

%% Parameters for Staircase
Param.Staircase.AngleDelta      = Curr_AngleDelta;        % start
Param.Staircase.MaxTrial        = 60;      
Param.Staircase.Up              = 1;        % increase after 1 wrong
Param.Staircase.Down            = 3;        % decrease after 3 consecutive right
Param.Staircase.StepSizeDown    = 0.5;           
Param.Staircase.StepSizeUp      = 0.5;      
Param.Staircase.StopCriterion1  = 'trials';   
Param.Staircase.StopRule1       = Param.DisBehav.TrialNum;  
Param.Staircase.ReversalsUsed1  = 3; 
Param.Staircase.StopCriterion2  = 'reversals';   
Param.Staircase.StopRule2       = 10;
Param.Staircase.ReversalsUsed2  = 4; 
Param.Staircase.xMax           = 15;              
Param.Staircase.xMin           = 0;

%% Parameters for spatial dots
Param.SpatialDot.DiskNum        = 2;
Param.SpatialDot.DotSize        = 0.15 * Param.Settings.PixelPerDegree;
Param.SpatialDot.OuterRadius    = 3.25 * Param.Settings.PixelPerDegree;
Param.SpatialDot.InnerRadius    = 0.3 * Param.Settings.PixelPerDegree;
Param.SpatialDot.RadiusJitter   = 0.6 * Param.Settings.PixelPerDegree;
Param.SpatialDot.AngleJitter    = 10;
Param.SpatialDot.DiskColor      = [255,0,0; 255,0,255; 0,165,0; 255,255,0; 0,0,255; 0,255,255];

% paradigm000 - ISI 0.9s, Sample1&2 display at the same time 0.8s, ISI 0.9s,
%             cue 1.2s, delay 3*TR, test 1.4s, response 2.4s
% paradigm-2 samples - ISI 0.6s, sample1 0.4s, ISI 0.6s, sample2 0.4s, 
%                   ISI 0.6s, cue 1.2s, delay 3*TR, test 1.4s, response 2.4s
% paradigm-3 samples - ISI 0.5s, sample1 0.3s, ISI 0.5s, sample2 0.3s, 
%                   ISI 0.5s, sample3 0.3s, ISI 0.5s, cue 0.9s, delay 3*TR, 
%                   test 1.4s, response 2.4s
% paradigm-4 samples - ISI 0.4s, sample1 0.2s, ISI 0.4s, sample2 0.2s, 
%                   ISI 0.4s, sample3 0.2s, ISI 0.4s, sample4 0.2s, ISI 0.4s, 
%                   cue 1.0s, delay 3*TR, test 1.4s, response 2.4s
% paradigm-5 samples - ISI 0.3s, sample1 0.2s, ISI 0.3s, sample2 0.2s, 
%                   ISI 0.3s, sample3 0.2s, ISI 0.3s, sample4 0.2s, ISI 0.3s, 
%                   sample5 0.2s, ISI 0.3s, cue 1.0s, delay 3*TR, test 1.4s, 
%                   response 2.4s
% paradigm color samples - ISI 0.8s, samples 1.0s, ISI 0.8s, cue 1.2s, 
%                   delay 3*TR, test 1.4s, response 2.4s
Param.SpatialDot.Duration1      = 0.6;
Param.SpatialDot.Duration2      = 0.4;
Param.SpatialDot.Duration3      = 0.3;
Param.SpatialDot.Duration4      = 0.2;
Param.SpatialDot.Duration5      = 0.2;
Param.SpatialDot.DurationColor  = 0.8;
Param.SpatialDot.testDuration   = 1.4;
Param.SpatialDot.OvalLoc        = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.SpatialDot.InnerRadius, ...
                                   Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.SpatialDot.InnerRadius, ...
                                   Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.SpatialDot.InnerRadius, ...
                                   Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.SpatialDot.InnerRadius];
% Param.SpatialDot.Jitter         = [0.1:0.2:1.5];
% Param.SpatialDot.Jitter         = 2*Param.Settings.PixelPerDegree; %[0.1:0.2:1.5];
% Param.SpatialDot.Jitter = 15;