function abort                                                 
    ShowCursor;
    Screen('closeall');
    reset_test_gamma;
    warning on;
    error('aborting due to user cancellation...');
end
