function reset_gamma

  % load gamma table
    clear reset
    
    path=fileparts(mfilename('fullpath'));
    load([path '\' 'reset_gamma.mat'],'reset_gamma_table');
    
    screencount=size(Screen('screens'),2);
    if screencount==1
        scr=1;
    else
        scr=screencount-1;
    end

    if (screencount==1)
            Screen('loadnormalizedgammatable',0,reset_gamma_table);
    else
        for (i=1:scr)
            Screen('loadnormalizedgammatable',i,reset_gamma_table);
        end
    end