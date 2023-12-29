% by Ke Jia
% 2022/11/07 14:26
% fixations for resting state fmri

%% Exp Start
Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
Screen('DrawLines', wnd, Param.Fixation.CrossLoc, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
% Screen('DrawLines', wnd, [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-200,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+200;Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2),Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)], Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);

Screen('Flip', wnd);

is_true = 0;
while (is_true == 0)
    [~,~,keyCode] = KbCheck;
    if keyCode(Param.Keys.EscPress)
        abort;
    end
end

delete *.asv  