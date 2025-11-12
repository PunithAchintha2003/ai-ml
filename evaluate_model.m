function evaluate_model()
%% EVALUATE_MODEL - Comprehensive model performance evaluation
% =========================================================================
% This function evaluates the trained neural network using multiple metrics:
%   - Classification accuracy
%   - Confusion matrix
%   - False Acceptance Rate (FAR)
%   - False Rejection Rate (FRR)
%   - Equal Error Rate (EER)
%   - TAR vs FAR curve (ROC-style)
%
% Definitions:
%   FAR: Probability that system accepts an impostor
%   FRR: Probability that system rejects a genuine user
%   EER: Point where FAR = FRR (lower is better)
%
% Output:
%   - results/evalResults.mat: evaluation metrics
%   - results/confusion_matrix.png
%   - results/FAR_FRR_curve.png
%   - results/TAR_vs_FAR.png
%
% Reference: [4] Jain et al., 2004 - An Introduction to Biometric Recognition
% =========================================================================

    fprintf('Loading trained model and test data...\n');
    load('results/baseline_model.mat', 'model');
    load('results/featuresTable.mat', 'allFeatures', 'allLabels');
    
    net = model.net;
    testIdx = model.testIdx;
    mu = model.mu;
    sigma = model.sigma;
    
    % Get test data
    X_test = allFeatures(testIdx, :);
    y_test = allLabels(testIdx);
    
    % Standardize
    X_test_norm = (X_test - mu) ./ sigma;
    
    % Map labels
    uniqueUsers = model.uniqueUsers;
    labelMap = model.labelMap;
    y_test_idx = zeros(size(y_test));
    for i = 1:length(y_test)
        y_test_idx(i) = labelMap(y_test(i));
    end
    
    %% Predict on Test Set
    fprintf('Computing predictions...\n');
    X_test_t = X_test_norm';
    y_pred_prob = net(X_test_t); % Softmax probabilities
    [~, y_pred_idx] = max(y_pred_prob);
    y_pred_idx = y_pred_idx';
    
    %% Accuracy
    accuracy = sum(y_pred_idx == y_test_idx) / length(y_test_idx) * 100;
    fprintf('Test Accuracy: %.2f%%\n', accuracy);
    
    %% Confusion Matrix
    fprintf('\nGenerating confusion matrix...\n');
    
    figure('Position', [100, 100, 800, 700]);
    confMat = confusionmat(y_test_idx, y_pred_idx);
    confChart = confusionchart(confMat, uniqueUsers);
    confChart.Title = 'Confusion Matrix - User Authentication';
    confChart.XLabel = 'Predicted User';
    confChart.YLabel = 'True User';
    
    saveas(gcf, 'results/confusion_matrix.png');
    fprintf('✓ Saved confusion_matrix.png\n');
    close(gcf);
    
    %% Compute FAR and FRR
    fprintf('\nComputing FAR, FRR, and EER...\n');
    
    numClasses = length(uniqueUsers);
    thresholds = linspace(0, 1, 1000);
    FAR_values = zeros(length(thresholds), 1);
    FRR_values = zeros(length(thresholds), 1);
    
    % For each threshold, compute FAR and FRR
    for t_idx = 1:length(thresholds)
        threshold = thresholds(t_idx);
        
        FA = 0; % False Acceptances
        FR = 0; % False Rejections
        totalGenuine = 0;
        totalImpostor = 0;
        
        % For each test sample
        for i = 1:length(y_test_idx)
            trueClass = y_test_idx(i);
            maxProb = max(y_pred_prob(:, i));
            predictedClass = y_pred_idx(i);
            
            % Decision: accept if maxProb >= threshold
            if maxProb >= threshold
                % System accepts
                if predictedClass ~= trueClass
                    FA = FA + 1; % False acceptance (impostor accepted)
                end
                totalImpostor = totalImpostor + 1;
            else
                % System rejects
                if predictedClass == trueClass
                    FR = FR + 1; % False rejection (genuine rejected)
                end
                totalGenuine = totalGenuine + 1;
            end
        end
        
        % Compute rates
        % Alternative: compute per-user FAR/FRR
        % Simplified: use all test samples
        totalTests = length(y_test_idx);
        FAR_values(t_idx) = FA / max(totalTests, 1);
        FRR_values(t_idx) = FR / max(totalTests, 1);
    end
    
    % Find EER (where FAR ≈ FRR)
    [~, eerIdx] = min(abs(FAR_values - FRR_values));
    EER = (FAR_values(eerIdx) + FRR_values(eerIdx)) / 2 * 100;
    EER_threshold = thresholds(eerIdx);
    
    fprintf('Equal Error Rate (EER): %.2f%%\n', EER);
    fprintf('EER Threshold: %.4f\n', EER_threshold);
    
    %% Plot FAR/FRR vs Threshold
    figure('Position', [100, 100, 900, 600]);
    plot(thresholds, FAR_values * 100, 'r-', 'LineWidth', 2, 'DisplayName', 'FAR');
    hold on;
    plot(thresholds, FRR_values * 100, 'b-', 'LineWidth', 2, 'DisplayName', 'FRR');
    plot(EER_threshold, EER, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'g', ...
         'DisplayName', sprintf('EER = %.2f%%', EER));
    hold off;
    
    xlabel('Threshold', 'FontSize', 12);
    ylabel('Error Rate (%)', 'FontSize', 12);
    title('FAR and FRR vs Decision Threshold', 'FontSize', 14, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 11);
    grid on;
    
    saveas(gcf, 'results/FAR_FRR_curve.png');
    fprintf('✓ Saved FAR_FRR_curve.png\n');
    close(gcf);
    
    %% TAR vs FAR (ROC-style curve)
    TAR_values = 1 - FRR_values; % True Acceptance Rate
    
    figure('Position', [100, 100, 800, 700]);
    plot(FAR_values * 100, TAR_values * 100, 'b-', 'LineWidth', 2);
    hold on;
    plot(FAR_values(eerIdx) * 100, TAR_values(eerIdx) * 100, 'ro', ...
         'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
         'DisplayName', sprintf('EER Point'));
    hold off;
    
    xlabel('False Acceptance Rate (%)', 'FontSize', 12);
    ylabel('True Acceptance Rate (%)', 'FontSize', 12);
    title('TAR vs FAR Curve (ROC-style)', 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    legend('Location', 'southeast', 'FontSize', 11);
    
    saveas(gcf, 'results/TAR_vs_FAR.png');
    fprintf('✓ Saved TAR_vs_FAR.png\n');
    close(gcf);
    
    %% Per-User Metrics
    fprintf('\n--- Per-User Performance ---\n');
    for i = 1:numClasses
        userID = uniqueUsers(i);
        userMask = (y_test_idx == i);
        userAccuracy = sum(y_pred_idx(userMask) == y_test_idx(userMask)) / sum(userMask) * 100;
        fprintf('User %d: %.2f%% accuracy (%d samples)\n', ...
            userID, userAccuracy, sum(userMask));
    end
    
    %% Save Results
    evalResults = struct();
    evalResults.accuracy = accuracy;
    evalResults.EER = EER;
    evalResults.EER_threshold = EER_threshold;
    evalResults.FAR_values = FAR_values;
    evalResults.FRR_values = FRR_values;
    evalResults.TAR_values = TAR_values;
    evalResults.thresholds = thresholds;
    evalResults.confusionMatrix = confMat;
    evalResults.y_test = y_test;
    evalResults.y_pred_idx = y_pred_idx;
    
    save('results/evalResults.mat', 'evalResults');
    
    fprintf('\n--- Evaluation Summary ---\n');
    fprintf('Test Accuracy: %.2f%%\n', accuracy);
    fprintf('Equal Error Rate (EER): %.2f%%\n', EER);
    fprintf('Results saved to results/evalResults.mat\n');
    fprintf('Generated plots:\n');
    fprintf('  - confusion_matrix.png\n');
    fprintf('  - FAR_FRR_curve.png\n');
    fprintf('  - TAR_vs_FAR.png\n');
end

