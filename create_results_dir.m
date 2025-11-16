function create_results_dir(config)
%% CREATE_RESULTS_DIR - Ensure results directory exists
% Input:
%   config: (optional) configuration struct with resultsPath

    if nargin < 1
        config = load_config();
    end
    
    if ~exist(config.resultsPath, 'dir')
        mkdir(config.resultsPath);
        fprintf('Created directory: %s\n', config.resultsPath);
    end
    
    if ~exist(config.figuresPath, 'dir') && ~strcmp(config.figuresPath, config.resultsPath)
        mkdir(config.figuresPath);
        fprintf('Created directory: %s\n', config.figuresPath);
    end
end

