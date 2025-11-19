function preprocess_data()
%% PREPROCESS_DATA - Clean and normalize accelerometer and gyroscope data
% =========================================================================
% This function reads raw CSV files from the Dataset/ folder, processes
% both accelerometer and gyroscope readings, and separates Day 1 and Day 2 data.
%
% Processing steps:
%   1. Read all user CSV files
%   2. Extract accelerometer data (columns 2-4: x, y, z)
%   3. Extract gyroscope data (columns 5-7: x, y, z)
%   4. Handle missing values
%   5. Detrend signals
%   6. Normalize signals
%   7. Save preprocessed data separated by day
%
% Output:
%   - results/preprocessed.mat containing:
%     * day1_accel: cell array of Day 1 accelerometer data per user
%     * day1_gyro: cell array of Day 1 gyroscope data per user
%     * day2_accel: cell array of Day 2 accelerometer data per user
%     * day2_gyro: cell array of Day 2 gyroscope data per user
%     * userLabels_day1: user IDs for Day 1
%     * userLabels_day2: user IDs for Day 2
%     * samplingRate: standardized sampling rate (30 Hz)
% =========================================================================

    fprintf('Reading raw sensor data from Dataset/ folder...\n');
    
    % Define dataset path
    dataPath = 'Dataset/';
    
    % Get all CSV files
    csvFiles = dir(fullfile(dataPath, '*.csv'));
    
    if isempty(csvFiles)
        error('No CSV files found in Dataset/ folder!');
    end
    
    fprintf('Found %d CSV files\n', length(csvFiles));
    
    % Initialize storage for Day 1 and Day 2
    day1_accel = {};
    day1_gyro = {};
    day2_accel = {};
    day2_gyro = {};
    userLabels_day1 = [];
    userLabels_day2 = [];
    samplingRate = 30; % Target sampling rate in Hz
    
    % Process each file
    for i = 1:length(csvFiles)
        filename = csvFiles(i).name;
        filepath = fullfile(dataPath, filename);
        
        fprintf('  Processing: %s ', filename);
        
        % Extract user ID from filename (e.g., U1NW_FD.csv -> user 1)
        userID = str2double(regexp(filename, '\d+', 'match', 'once'));
        
        % Determine if this is Day 1 (FD) or Day 2 (MD)
        if contains(filename, '_FD.csv')
            isDay1 = true;
        elseif contains(filename, '_MD.csv')
            isDay1 = false;
        else
            warning('File %s does not match expected naming pattern, skipping...', filename);
            continue;
        end
        
        % Read CSV file
        try
            data = readmatrix(filepath);
            
            % Extract accelerometer columns (columns 2-4: x, y, z)
            if size(data, 2) >= 7
                accelData = data(:, 2:4);
                gyroData = data(:, 5:7);
            else
                warning('File %s has unexpected format, skipping...', filename);
                continue;
            end
            
            % Process accelerometer data
            for col = 1:3
                % Handle missing values
                if any(isnan(accelData(:, col)))
                    accelData(:, col) = fillmissing(accelData(:, col), 'linear');
                end
                % Detrend
                accelData(:, col) = detrend(accelData(:, col));
                % Normalize
                accelData(:, col) = (accelData(:, col) - mean(accelData(:, col))) / (std(accelData(:, col)) + eps);
            end
            
            % Process gyroscope data
            for col = 1:3
                % Handle missing values
                if any(isnan(gyroData(:, col)))
                    gyroData(:, col) = fillmissing(gyroData(:, col), 'linear');
                end
                % Detrend
                gyroData(:, col) = detrend(gyroData(:, col));
                % Normalize
                gyroData(:, col) = (gyroData(:, col) - mean(gyroData(:, col))) / (std(gyroData(:, col)) + eps);
            end
            
            % Store processed data based on day
            if isDay1
                day1_accel{end+1} = accelData;
                day1_gyro{end+1} = gyroData;
                userLabels_day1(end+1) = userID;
                fprintf('✓ Day 1 (%d samples, User %d)\n', size(accelData, 1), userID);
            else
                day2_accel{end+1} = accelData;
                day2_gyro{end+1} = gyroData;
                userLabels_day2(end+1) = userID;
                fprintf('✓ Day 2 (%d samples, User %d)\n', size(accelData, 1), userID);
            end
            
        catch ME
            warning('Error processing %s: %s', filename, ME.message);
            continue;
        end
    end
    
    % Summary statistics
    fprintf('\n--- Preprocessing Summary ---\n');
    fprintf('Day 1 files processed: %d\n', length(day1_accel));
    fprintf('Day 2 files processed: %d\n', length(day2_accel));
    fprintf('Unique users (Day 1): %d\n', length(unique(userLabels_day1)));
    fprintf('Unique users (Day 2): %d\n', length(unique(userLabels_day2)));
    fprintf('Target sampling rate: %d Hz\n', samplingRate);
    
    totalSamples_day1 = 0;
    for i = 1:length(day1_accel)
        totalSamples_day1 = totalSamples_day1 + size(day1_accel{i}, 1);
    end
    totalSamples_day2 = 0;
    for i = 1:length(day2_accel)
        totalSamples_day2 = totalSamples_day2 + size(day2_accel{i}, 1);
    end
    
    fprintf('Total samples (Day 1): %d\n', totalSamples_day1);
    fprintf('Total samples (Day 2): %d\n', totalSamples_day2);
    fprintf('Average samples per file (Day 1): %.1f\n', totalSamples_day1 / length(day1_accel));
    fprintf('Average samples per file (Day 2): %.1f\n', totalSamples_day2 / length(day2_accel));
    
    % Save preprocessed data
    save('results/preprocessed.mat', 'day1_accel', 'day1_gyro', 'day2_accel', 'day2_gyro', ...
         'userLabels_day1', 'userLabels_day2', 'samplingRate');
    fprintf('\nPreprocessed data saved to results/preprocessed.mat\n');
end

