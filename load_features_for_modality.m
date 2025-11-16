function [X, y] = load_features_for_modality(modality, day)
%% LOAD_FEATURES_FOR_MODALITY - Load feature matrix for given modality and day
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%   day: 1 or 2
% Output:
%   X: Feature matrix
%   y: Labels

    % Validate inputs
    validate_modality(modality);
    if ~ismember(day, [1, 2])
        error('Day must be 1 or 2');
    end
    
    % Construct filename
    dayStr = sprintf('d%d', day);
    filename = sprintf('results/features_day%d_%s.mat', day, lower(modality));
    
    % Check if file exists
    if ~exist(filename, 'file')
        error('Feature file not found: %s\nPlease run extract_features() first.', filename);
    end
    
    % Load based on modality and day
    switch lower(modality)
        case 'accel'
            varName = sprintf('features_%s_accel', dayStr);
            labelName = sprintf('labels_%s_accel', dayStr);
            data = load(filename, varName, labelName);
            X = data.(varName);
            y = data.(labelName);
        case 'gyro'
            varName = sprintf('features_%s_gyro', dayStr);
            labelName = sprintf('labels_%s_gyro', dayStr);
            data = load(filename, varName, labelName);
            X = data.(varName);
            y = data.(labelName);
        case 'combined'
            varName = sprintf('features_%s_combined', dayStr);
            labelName = sprintf('labels_%s_combined', dayStr);
            data = load(filename, varName, labelName);
            X = data.(varName);
            y = data.(labelName);
    end
    
    % Validate loaded data
    if isempty(X) || isempty(y)
        error('Loaded features or labels are empty');
    end
    
    if size(X, 1) ~= length(y)
        error('Feature matrix and label vector have mismatched dimensions');
    end
end

