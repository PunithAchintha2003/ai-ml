function evalResults = evaluate(trainedModel)
%% EVALUATE - Compute FAR, FRR, and EER for trained model
% =========================================================================
% Input:
%   trainedModel: struct from train_test_scenarioX.m containing:
%                 - y_test_pred_prob: prediction probabilities
%                 - y_test_idx: true labels
%                 - uniqueUsers: list of user IDs
%
% Output:
%   evalResults: struct containing FAR, FRR, EER, and related metrics
% =========================================================================

    fprintf('\n--- Computing FAR, FRR, and EER ---\n');
    
    % Extract data from trained model
    y_pred_prob = trainedModel.y_test_pred_prob;
    y_test_idx = trainedModel.y_test_idx;
    numClasses = trainedModel.numClasses;
    uniqueUsers = trainedModel.uniqueUsers;
    
    % Get predicted labels
    [maxProb, y_pred_idx] = max(y_pred_prob, [], 2);
    
    % Compute accuracy
    accuracy = sum(y_pred_idx == y_test_idx) / length(y_test_idx) * 100;
    fprintf('Test Accuracy: %.2f%%\n', accuracy);
    
    %% Compute FAR and FRR across thresholds
    thresholds = linspace(0, 1, 1000);
    FAR_values = zeros(length(thresholds), 1);
    FRR_values = zeros(length(thresholds), 1);
    
    fprintf('Computing FAR and FRR across %d thresholds...\n', length(thresholds));
    
    % For each threshold, compute FAR and FRR
    for t_idx = 1:length(thresholds)
        threshold = thresholds(t_idx);
        
        totalFA = 0;
        totalFR = 0;
        totalGenuine = 0;
        totalImpostor = 0;
        
        % Compute per-user then average
        for userClass = 1:numClasses
            % Genuine attempts: samples that truly belong to this user
            genuineMask = (y_test_idx == userClass);
            genuineCount = sum(genuineMask);
            totalGenuine = totalGenuine + genuineCount;
            
            % Impostor attempts: samples that don't belong to this user
            impostorMask = (y_test_idx ~= userClass);
            impostorCount = sum(impostorMask);
            totalImpostor = totalImpostor + impostorCount;
            
            if genuineCount > 0
                % False Rejections: genuine samples rejected
                % Rejected if: predicted wrong OR confidence too low
                rejected = (y_pred_idx ~= userClass) | (maxProb < threshold);
                FR = sum(genuineMask & rejected);
                totalFR = totalFR + FR;
            end
            
            if impostorCount > 0
                % False Acceptances: impostor samples accepted as this user
                % Accepted if: predicted as this user AND confidence >= threshold
                accepted = (y_pred_idx == userClass) & (maxProb >= threshold);
                FA = sum(impostorMask & accepted);
                totalFA = totalFA + FA;
            end
        end
        
        % Compute rates
        FAR_values(t_idx) = totalFA / max(totalImpostor, 1);
        FRR_values(t_idx) = totalFR / max(totalGenuine, 1);
    end
    
    %% Find EER (where FAR ≈ FRR)
    [~, eerIdx] = min(abs(FAR_values - FRR_values));
    EER = (FAR_values(eerIdx) + FRR_values(eerIdx)) / 2 * 100;
    EER_threshold = thresholds(eerIdx);
    
    fprintf('✓ Equal Error Rate (EER): %.2f%%\n', EER);
    fprintf('  EER Threshold: %.4f\n', EER_threshold);
    fprintf('  FAR at EER: %.2f%%\n', FAR_values(eerIdx) * 100);
    fprintf('  FRR at EER: %.2f%%\n', FRR_values(eerIdx) * 100);
    
    %% Generate confusion matrix
    confMat = confusionmat(y_test_idx, y_pred_idx);
    
    %% Per-User FAR and FRR
    fprintf('\n--- Per-User Authentication Metrics ---\n');
    perUserFAR = zeros(numClasses, 1);
    perUserFRR = zeros(numClasses, 1);
    
    for i = 1:numClasses
        userID = uniqueUsers(i);
        
        % Genuine attempts for this user (true class = i)
        genuineMask = (y_test_idx == i);
        genuineAttempts = sum(genuineMask);
        
        if genuineAttempts > 0
            % False rejections: genuine user predicted as someone else
            falseRejections = sum(genuineMask & (y_pred_idx ~= i));
            perUserFRR(i) = (falseRejections / genuineAttempts) * 100;
            
            % Impostor attempts: others predicted as this user
            impostorMask = (y_test_idx ~= i);
            falseAcceptances = sum(impostorMask & (y_pred_idx == i));
            impostorAttempts = sum(impostorMask);
            
            if impostorAttempts > 0
                perUserFAR(i) = (falseAcceptances / impostorAttempts) * 100;
            else
                perUserFAR(i) = 0;
            end
            
            fprintf('User %d: FAR=%.2f%%, FRR=%.2f%% (%d genuine samples)\n', ...
                userID, perUserFAR(i), perUserFRR(i), genuineAttempts);
        end
    end
    
    %% TAR (True Acceptance Rate) vs FAR
    TAR_values = 1 - FRR_values;
    
    %% Package results
    evalResults = struct();
    evalResults.accuracy = accuracy;
    evalResults.EER = EER;
    evalResults.EER_threshold = EER_threshold;
    evalResults.FAR_values = FAR_values;
    evalResults.FRR_values = FRR_values;
    evalResults.TAR_values = TAR_values;
    evalResults.thresholds = thresholds;
    evalResults.confusionMatrix = confMat;
    evalResults.perUserFAR = perUserFAR;
    evalResults.perUserFRR = perUserFRR;
    evalResults.y_test_idx = y_test_idx;
    evalResults.y_pred_idx = y_pred_idx;
    evalResults.scenario = trainedModel.scenario;
    evalResults.modality = trainedModel.modality;
    
    fprintf('\n--- Evaluation Summary ---\n');
    fprintf('Scenario: %d\n', trainedModel.scenario);
    fprintf('Modality: %s\n', upper(trainedModel.modality));
    fprintf('Test Accuracy: %.2f%%\n', accuracy);
    fprintf('Equal Error Rate (EER): %.2f%%\n', EER);
    fprintf('Average FAR: %.2f%%\n', mean(perUserFAR));
    fprintf('Average FRR: %.2f%%\n', mean(perUserFRR));
    
    %% Interpret EER
    fprintf('\n--- EER Interpretation ---\n');
    if EER < 1
        fprintf('✓ Exceptional (fingerprint-level security)\n');
    elseif EER < 5
        fprintf('✓ Excellent (commercial-grade security)\n');
    elseif EER < 10
        fprintf('○ Good (acceptable for low-risk applications)\n');
    elseif EER < 20
        fprintf('△ Fair (needs improvement)\n');
    else
        fprintf('✗ Poor (not viable for authentication)\n');
    end
    
    fprintf('========================================\n');
end

