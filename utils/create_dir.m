function create_dir(cfg)
%% CREATE_DIR - Ensure results directory exists
% Input:
%   cfg: (optional) configuration struct with resultsPath

    if nargin < 1
        cfg = config();
    end
    
    if ~exist(cfg.resultsPath, 'dir')
        mkdir(cfg.resultsPath);
        fprintf('Created directory: %s\n', cfg.resultsPath);
    end
    
    if ~exist(cfg.figuresPath, 'dir') && ~strcmp(cfg.figuresPath, cfg.resultsPath)
        mkdir(cfg.figuresPath);
        fprintf('Created directory: %s\n', cfg.figuresPath);
    end
end

