function extract_features()
%% EXTRACT_FEATURES - Extract time and frequency domain features
% =========================================================================
% This function segments preprocessed sensor signals into windows
% and computes comprehensive features for user authentication.
%
% Supports three modalities:
%   1. Accelerometer only
%   2. Gyroscope only
%   3. Combined (accelerometer + gyroscope)
%
% Features computed (per window):
%   Time Domain:
%     - Mean, Std, Variance, Skewness, Kurtosis
%     - Min, Max, Median, Range, IQR
%     - Root Mean Square (RMS), Zero Crossing Rate
%   
%   Frequency Domain:
%     - Dominant frequency, Spectral entropy
%     - Energy, Power Spectral Density metrics
%   
%   Cross-axis Features:
%     - Correlation coefficients (xy, xz, yz)
%   
%   Magnitude Features:
%     - Mean, Std, Energy of magnitude signal
%
% Window Configuration:
%   - Window size: 4 seconds (per requirements)
%   - Overlap: 50%
%
% Output:
%   - results/features_day1_accel.mat
%   - results/features_day1_gyro.mat
%   - results/features_day1_combined.mat
%   - results/features_day2_accel.mat
%   - results/features_day2_gyro.mat
%   - results/features_day2_combined.mat
%
% Reference: [2] Wang et al., 2016 - Deep Learning for Sensor-based Activity Recognition
% =========================================================================

    fprintf('Loading preprocessed data...\n');
    load('results/preprocessed.mat', 'day1_accel', 'day1_gyro', 'day2_accel', 'day2_gyro', ...
         'userLabels_day1', 'userLabels_day2', 'samplingRate');
    
    % Window parameters (4 seconds per requirements)
    windowSize = 4.0; % seconds
    overlap = 0.5; % 50% overlap
    windowSamples = round(windowSize * samplingRate);
    stepSamples = round(windowSamples * (1 - overlap));
    
    fprintf('Window size: %.1f seconds (%d samples)\n', windowSize, windowSamples);
    fprintf('Overlap: %.0f%% (step: %d samples)\n', overlap*100, stepSamples);
    
    %% Extract features for all combinations
    % Day 1 - Accelerometer only
    fprintf('\n=== Extracting Day 1 - Accelerometer Features ===\n');
    [features_d1_accel, labels_d1_accel, names_accel] = extractModalityFeatures(...
        day1_accel, userLabels_day1, windowSamples, stepSamples, samplingRate, 'Accel');
    save('results/features_day1_accel.mat', 'features_d1_accel', 'labels_d1_accel', 'names_accel');
    fprintf('✓ Saved features_day1_accel.mat\n');
    
    % Day 1 - Gyroscope only
    fprintf('\n=== Extracting Day 1 - Gyroscope Features ===\n');
    [features_d1_gyro, labels_d1_gyro, names_gyro] = extractModalityFeatures(...
        day1_gyro, userLabels_day1, windowSamples, stepSamples, samplingRate, 'Gyro');
    save('results/features_day1_gyro.mat', 'features_d1_gyro', 'labels_d1_gyro', 'names_gyro');
    fprintf('✓ Saved features_day1_gyro.mat\n');
    
    % Day 1 - Combined
    fprintf('\n=== Extracting Day 1 - Combined Features ===\n');
    [features_d1_combined, labels_d1_combined, names_combined] = extractCombinedFeatures(...
        day1_accel, day1_gyro, userLabels_day1, windowSamples, stepSamples, samplingRate);
    save('results/features_day1_combined.mat', 'features_d1_combined', 'labels_d1_combined', 'names_combined');
    fprintf('✓ Saved features_day1_combined.mat\n');
    
    % Day 2 - Accelerometer only
    fprintf('\n=== Extracting Day 2 - Accelerometer Features ===\n');
    [features_d2_accel, labels_d2_accel, ~] = extractModalityFeatures(...
        day2_accel, userLabels_day2, windowSamples, stepSamples, samplingRate, 'Accel');
    save('results/features_day2_accel.mat', 'features_d2_accel', 'labels_d2_accel', 'names_accel');
    fprintf('✓ Saved features_day2_accel.mat\n');
    
    % Day 2 - Gyroscope only
    fprintf('\n=== Extracting Day 2 - Gyroscope Features ===\n');
    [features_d2_gyro, labels_d2_gyro, ~] = extractModalityFeatures(...
        day2_gyro, userLabels_day2, windowSamples, stepSamples, samplingRate, 'Gyro');
    save('results/features_day2_gyro.mat', 'features_d2_gyro', 'labels_d2_gyro', 'names_gyro');
    fprintf('✓ Saved features_day2_gyro.mat\n');
    
    % Day 2 - Combined
    fprintf('\n=== Extracting Day 2 - Combined Features ===\n');
    [features_d2_combined, labels_d2_combined, ~] = extractCombinedFeatures(...
        day2_accel, day2_gyro, userLabels_day2, windowSamples, stepSamples, samplingRate);
    save('results/features_day2_combined.mat', 'features_d2_combined', 'labels_d2_combined', 'names_combined');
    fprintf('✓ Saved features_day2_combined.mat\n');
    
    % Summary
    fprintf('\n=================================================\n');
    fprintf('FEATURE EXTRACTION SUMMARY\n');
    fprintf('=================================================\n');
    fprintf('Day 1 - Accelerometer: %d windows, %d features\n', size(features_d1_accel, 1), size(features_d1_accel, 2));
    fprintf('Day 1 - Gyroscope: %d windows, %d features\n', size(features_d1_gyro, 1), size(features_d1_gyro, 2));
    fprintf('Day 1 - Combined: %d windows, %d features\n', size(features_d1_combined, 1), size(features_d1_combined, 2));
    fprintf('Day 2 - Accelerometer: %d windows, %d features\n', size(features_d2_accel, 1), size(features_d2_accel, 2));
    fprintf('Day 2 - Gyroscope: %d windows, %d features\n', size(features_d2_gyro, 1), size(features_d2_gyro, 2));
    fprintf('Day 2 - Combined: %d windows, %d features\n', size(features_d2_combined, 1), size(features_d2_combined, 2));
    fprintf('=================================================\n');
end

function [allFeatures, allLabels, featureNames] = extractModalityFeatures(dataCell, userLabels, windowSamples, stepSamples, fs, sensorType)
%% Extract features from single modality (accelerometer or gyroscope)
    allFeatures = [];
    allLabels = [];
    
    for fileIdx = 1:length(dataCell)
        sensorData = dataCell{fileIdx};
        userID = userLabels(fileIdx);
        numSamples = size(sensorData, 1);
        
        fprintf('  User %d: ', userID);
        
        windowCount = 0;
        for startIdx = 1:stepSamples:(numSamples - windowSamples + 1)
            endIdx = startIdx + windowSamples - 1;
            
            % Extract window
            window = sensorData(startIdx:endIdx, :);
            x = window(:, 1);
            y = window(:, 2);
            z = window(:, 3);
            
            % Compute features
            features = computeWindowFeatures(x, y, z, fs);
            
            % Store
            allFeatures = [allFeatures; features];
            allLabels = [allLabels; userID];
            windowCount = windowCount + 1;
        end
        
        fprintf('%d windows\n', windowCount);
    end
    
    % Generate feature names
    featureNames = generateFeatureNames(sensorType);
    
    fprintf('  Total: %d windows, %d features per window\n', size(allFeatures, 1), size(allFeatures, 2));
end

function [allFeatures, allLabels, featureNames] = extractCombinedFeatures(accelCell, gyroCell, userLabels, windowSamples, stepSamples, fs)
%% Extract features from combined accelerometer + gyroscope data
    allFeatures = [];
    allLabels = [];
    
    for fileIdx = 1:length(accelCell)
        accelData = accelCell{fileIdx};
        gyroData = gyroCell{fileIdx};
        userID = userLabels(fileIdx);
        numSamples = min(size(accelData, 1), size(gyroData, 1));
        
        fprintf('  User %d: ', userID);
        
        windowCount = 0;
        for startIdx = 1:stepSamples:(numSamples - windowSamples + 1)
            endIdx = startIdx + windowSamples - 1;
            
            % Extract windows
            accelWindow = accelData(startIdx:endIdx, :);
            gyroWindow = gyroData(startIdx:endIdx, :);
            
            % Compute features for both
            accelFeatures = computeWindowFeatures(accelWindow(:,1), accelWindow(:,2), accelWindow(:,3), fs);
            gyroFeatures = computeWindowFeatures(gyroWindow(:,1), gyroWindow(:,2), gyroWindow(:,3), fs);
            
            % Concatenate
            features = [accelFeatures, gyroFeatures];
            
            % Store
            allFeatures = [allFeatures; features];
            allLabels = [allLabels; userID];
            windowCount = windowCount + 1;
        end
        
        fprintf('%d windows\n', windowCount);
    end
    
    % Generate combined feature names
    accelNames = generateFeatureNames('Accel');
    gyroNames = generateFeatureNames('Gyro');
    featureNames = [accelNames, gyroNames];
    
    fprintf('  Total: %d windows, %d features per window\n', size(allFeatures, 1), size(allFeatures, 2));
end

function features = computeWindowFeatures(x, y, z, fs)
%% COMPUTE_WINDOW_FEATURES - Extract all features from a single window
% =========================================================================
    
    % Initialize feature vector
    features = [];
    
    %% Time Domain Features (per axis)
    for signal = {x, y, z}
        s = signal{1};
        
        % Basic statistics
        features(end+1) = mean(s);
        features(end+1) = std(s);
        features(end+1) = var(s);
        features(end+1) = skewness(s);
        features(end+1) = kurtosis(s);
        features(end+1) = min(s);
        features(end+1) = max(s);
        features(end+1) = median(s);
        features(end+1) = range(s);
        features(end+1) = iqr(s);
        features(end+1) = rms(s);
        
        % Zero crossing rate
        zcr = sum(abs(diff(sign(s)))) / (2 * length(s));
        features(end+1) = zcr;
    end
    
    %% Frequency Domain Features (per axis)
    for signal = {x, y, z}
        s = signal{1};
        
        % FFT
        N = length(s);
        Y = fft(s);
        P = abs(Y/N);
        P = P(1:N/2+1);
        P(2:end-1) = 2*P(2:end-1);
        f = fs*(0:(N/2))/N;
        
        % Dominant frequency
        [~, idx] = max(P);
        features(end+1) = f(idx);
        
        % Spectral entropy
        P_norm = P / sum(P);
        P_norm(P_norm == 0) = eps; % Avoid log(0)
        spectralEntropy = -sum(P_norm .* log2(P_norm));
        features(end+1) = spectralEntropy;
        
        % Energy
        energy = sum(s.^2);
        features(end+1) = energy;
    end
    
    %% Cross-axis Correlation
    features(end+1) = corr(x, y);
    features(end+1) = corr(x, z);
    features(end+1) = corr(y, z);
    
    %% Magnitude-based Features
    magnitude = sqrt(x.^2 + y.^2 + z.^2);
    features(end+1) = mean(magnitude);
    features(end+1) = std(magnitude);
    features(end+1) = sum(magnitude.^2);
    
    % Convert to row vector
    features = features(:)';
end

function featureNames = generateFeatureNames(sensorType)
%% GENERATE_FEATURE_NAMES - Create descriptive names for all features
% =========================================================================
    
    axes = {'X', 'Y', 'Z'};
    featureNames = {};
    
    % Time domain features
    timeDomainFeats = {'Mean', 'Std', 'Var', 'Skew', 'Kurt', 'Min', 'Max', ...
                       'Median', 'Range', 'IQR', 'RMS', 'ZCR'};
    for axis = axes
        for feat = timeDomainFeats
            featureNames{end+1} = sprintf('%s_%s_%s', sensorType, feat{1}, axis{1});
        end
    end
    
    % Frequency domain features
    freqDomainFeats = {'DomFreq', 'SpecEntropy', 'Energy'};
    for axis = axes
        for feat = freqDomainFeats
            featureNames{end+1} = sprintf('%s_%s_%s', sensorType, feat{1}, axis{1});
        end
    end
    
    % Cross-axis correlation
    featureNames{end+1} = sprintf('%s_Corr_XY', sensorType);
    featureNames{end+1} = sprintf('%s_Corr_XZ', sensorType);
    featureNames{end+1} = sprintf('%s_Corr_YZ', sensorType);
    
    % Magnitude features
    featureNames{end+1} = sprintf('%s_Mag_Mean', sensorType);
    featureNames{end+1} = sprintf('%s_Mag_Std', sensorType);
    featureNames{end+1} = sprintf('%s_Mag_Energy', sensorType);
end

