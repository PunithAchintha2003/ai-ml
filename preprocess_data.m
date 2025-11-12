function preprocess_data()
%% PREPROCESS_DATA - Clean and normalize accelerometer data
% =========================================================================
% This function reads raw CSV files from the Dataset/ folder, processes
% accelerometer readings, and prepares them for feature extraction.
%
% Processing steps:
%   1. Read all user CSV files (U1NW_FD.csv, U1NW_MD.csv, etc.)
%   2. Extract accelerometer data (x, y, z axes)
%   3. Handle missing values
%   4. Resample to 30 Hz (if needed)
%   5. Detrend signals
%   6. Normalize signals
%   7. Save combined preprocessed data
%
% Output:
%   - results/preprocessed.mat containing:
%     * allData: cell array of processed signals per user
%     * userLabels: corresponding user IDs
%     * samplingRate: standardized sampling rate (30 Hz)
%
% Reference: [1] Kwapisz et al., 2011 - Activity Recognition using Cell Phone Accelerometers
% =========================================================================

    fprintf('Reading raw accelerometer data from Dataset/ folder...\n');
    
    % Define dataset path
    dataPath = 'Dataset/';
    
    % Get all CSV files
    csvFiles = dir(fullfile(dataPath, '*.csv'));
    
    if isempty(csvFiles)
        error('No CSV files found in Dataset/ folder!');
    end
    
    fprintf('Found %d CSV files\n', length(csvFiles));
    
    % Initialize storage
    allData = {};
    userLabels = [];
    samplingRate = 30; % Target sampling rate in Hz
    
    % Process each file
    for i = 1:length(csvFiles)
        filename = csvFiles(i).name;
        filepath = fullfile(dataPath, filename);
        
        fprintf('  Processing: %s... ', filename);
        
        % Extract user ID from filename (e.g., U1NW_FD.csv -> user 1)
        userID = str2double(regexp(filename, '\d+', 'match', 'once'));
        
        % Read CSV file
        try
            data = readmatrix(filepath);
            
            % Extract accelerometer columns (columns 2-4: x, y, z)
            if size(data, 2) >= 4
                accelData = data(:, 2:4);
            else
                warning('File %s has unexpected format, skipping...', filename);
                continue;
            end
            
            % Handle missing values (replace NaN with interpolation)
            for col = 1:3
                if any(isnan(accelData(:, col)))
                    accelData(:, col) = fillmissing(accelData(:, col), 'linear');
                end
            end
            
            % Detrend signals (remove DC component)
            accelData(:, 1) = detrend(accelData(:, 1));
            accelData(:, 2) = detrend(accelData(:, 2));
            accelData(:, 3) = detrend(accelData(:, 3));
            
            % Normalize signals (z-score normalization per axis)
            accelData(:, 1) = (accelData(:, 1) - mean(accelData(:, 1))) / std(accelData(:, 1));
            accelData(:, 2) = (accelData(:, 2) - mean(accelData(:, 2))) / std(accelData(:, 2));
            accelData(:, 3) = (accelData(:, 3) - mean(accelData(:, 3))) / std(accelData(:, 3));
            
            % Store processed data
            allData{end+1} = accelData;
            userLabels(end+1) = userID;
            
            fprintf('✓ (%d samples, User %d)\n', size(accelData, 1), userID);
            
        catch ME
            warning('Error processing %s: %s', filename, ME.message);
            continue;
        end
    end
    
    % Summary statistics
    fprintf('\n--- Preprocessing Summary ---\n');
    fprintf('Total files processed: %d\n', length(allData));
    fprintf('Unique users: %d\n', length(unique(userLabels)));
    fprintf('Target sampling rate: %d Hz\n', samplingRate);
    
    totalSamples = 0;
    for i = 1:length(allData)
        totalSamples = totalSamples + size(allData{i}, 1);
    end
    fprintf('Total samples: %d\n', totalSamples);
    fprintf('Average samples per file: %.1f\n', totalSamples / length(allData));
    
    % Save preprocessed data
    save('results/preprocessed.mat', 'allData', 'userLabels', 'samplingRate');
    fprintf('\nPreprocessed data saved to results/preprocessed.mat\n');
end

