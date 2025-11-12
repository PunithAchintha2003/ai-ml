function extract_features()
%% EXTRACT_FEATURES - Extract time and frequency domain features
% =========================================================================
% This function segments preprocessed accelerometer signals into windows
% and computes comprehensive features for user authentication.
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
%   - Window size: 2 seconds
%   - Overlap: 50%
%
% Output:
%   - results/featuresTable.mat containing feature matrix and labels
%
% Reference: [2] Wang et al., 2016 - Deep Learning for Sensor-based Activity Recognition
% =========================================================================

    fprintf('Loading preprocessed data...\n');
    load('results/preprocessed.mat', 'allData', 'userLabels', 'samplingRate');
    
    % Window parameters
    windowSize = 2.0; % seconds
    overlap = 0.5; % 50% overlap
    windowSamples = round(windowSize * samplingRate);
    stepSamples = round(windowSamples * (1 - overlap));
    
    fprintf('Window size: %.1f seconds (%d samples)\n', windowSize, windowSamples);
    fprintf('Overlap: %.0f%% (step: %d samples)\n', overlap*100, stepSamples);
    
    % Initialize feature storage
    allFeatures = [];
    allLabels = [];
    
    % Process each user's data
    for fileIdx = 1:length(allData)
        accelData = allData{fileIdx};
        userID = userLabels(fileIdx);
        numSamples = size(accelData, 1);
        
        fprintf('Extracting features from User %d file %d... ', userID, fileIdx);
        
        % Sliding window segmentation
        windowCount = 0;
        for startIdx = 1:stepSamples:(numSamples - windowSamples + 1)
            endIdx = startIdx + windowSamples - 1;
            
            % Extract window
            window = accelData(startIdx:endIdx, :);
            x = window(:, 1);
            y = window(:, 2);
            z = window(:, 3);
            
            % Compute features
            features = computeWindowFeatures(x, y, z, samplingRate);
            
            % Store
            allFeatures = [allFeatures; features];
            allLabels = [allLabels; userID];
            windowCount = windowCount + 1;
        end
        
        fprintf('✓ Extracted %d windows\n', windowCount);
    end
    
    % Create feature table
    featureNames = generateFeatureNames();
    featuresTable = array2table(allFeatures, 'VariableNames', featureNames);
    featuresTable.UserID = allLabels;
    
    % Summary
    fprintf('\n--- Feature Extraction Summary ---\n');
    fprintf('Total windows: %d\n', size(allFeatures, 1));
    fprintf('Features per window: %d\n', size(allFeatures, 2));
    fprintf('Users: %d\n', length(unique(allLabels)));
    
    % Display class distribution
    fprintf('\nClass distribution:\n');
    uniqueUsers = unique(allLabels);
    for i = 1:length(uniqueUsers)
        userID = uniqueUsers(i);
        count = sum(allLabels == userID);
        fprintf('  User %d: %d windows (%.1f%%)\n', userID, count, 100*count/length(allLabels));
    end
    
    % Save features
    save('results/featuresTable.mat', 'featuresTable', 'allFeatures', 'allLabels', 'featureNames');
    fprintf('\nFeatures saved to results/featuresTable.mat\n');
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

function featureNames = generateFeatureNames()
%% GENERATE_FEATURE_NAMES - Create descriptive names for all features
% =========================================================================
    
    axes = {'X', 'Y', 'Z'};
    featureNames = {};
    
    % Time domain features
    timeDomainFeats = {'Mean', 'Std', 'Var', 'Skew', 'Kurt', 'Min', 'Max', ...
                       'Median', 'Range', 'IQR', 'RMS', 'ZCR'};
    for axis = axes
        for feat = timeDomainFeats
            featureNames{end+1} = sprintf('%s_%s', feat{1}, axis{1});
        end
    end
    
    % Frequency domain features
    freqDomainFeats = {'DomFreq', 'SpecEntropy', 'Energy'};
    for axis = axes
        for feat = freqDomainFeats
            featureNames{end+1} = sprintf('%s_%s', feat{1}, axis{1});
        end
    end
    
    % Cross-axis correlation
    featureNames{end+1} = 'Corr_XY';
    featureNames{end+1} = 'Corr_XZ';
    featureNames{end+1} = 'Corr_YZ';
    
    % Magnitude features
    featureNames{end+1} = 'Mag_Mean';
    featureNames{end+1} = 'Mag_Std';
    featureNames{end+1} = 'Mag_Energy';
end

