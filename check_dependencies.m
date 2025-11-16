function check_dependencies()
%% CHECK_DEPENDENCIES - Verify required toolboxes are installed

    fprintf('Checking MATLAB toolbox dependencies...\n');
    
    required = {
        'Deep Learning Toolbox', 'nnet_cnn';
        'Statistics and Machine Learning Toolbox', 'stats';
        'Signal Processing Toolbox', 'signal'
    };
    
    allPresent = true;
    for i = 1:size(required, 1)
        toolboxName = required{i, 1};
        toolboxShort = required{i, 2};
        
        if license('test', toolboxShort)
            fprintf('  ✓ %s\n', toolboxName);
        else
            fprintf('  ✗ %s (MISSING)\n', toolboxName);
            allPresent = false;
        end
    end
    
    if ~allPresent
        warning('Some required toolboxes are missing. Continuing anyway...');
    else
        fprintf('All dependencies satisfied!\n\n');
    end
end

