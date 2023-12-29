function set_test_gamma

    % load gamma table
    path=fileparts(mfilename('fullpath'));
    load([path '\' 'test_gamma.mat'],'test_gamma_table');
    
    Screen('loadnormalizedgammatable',0,test_gamma_table);
    
    
    