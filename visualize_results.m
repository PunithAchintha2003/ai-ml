%% VISUALIZE_RESULTS - Generate comprehensive visualizations for all experiments
% =========================================================================
% This script creates professional visualizations comparing:
%   - Performance across scenarios
%   - Performance across modalities
%   - FAR/FRR curves for all configurations
%   - EER comparison bar charts
%   - Confusion matrices
%
% Run this after run_experiments.m completes
%
% Output:
%   - results/comparison_accuracy.png
%   - results/comparison_eer.png
%   - results/far_frr_scenario1.png
%   - results/far_frr_scenario2.png
%   - results/far_frr_scenario3.png
%   - results/confusion_matrices.png
%   - results/modality_comparison.png
% =========================================================================

clear all; close all; clc;

fprintf('============================================================\n');
fprintf('GENERATING VISUALIZATIONS FOR ALL EXPERIMENTS\n');
fprintf('============================================================\n\n');

% Load all experimental results
fprintf('Loading experimental results...\n');

% Check for optimized results first, then fallback to original
if exist('results/all_experiments_optimized.mat', 'file')
    fprintf('Found optimized results file\n');
    load('results/all_experiments_optimized.mat', 'allResults', 'allEvaluations', 'comparisonTable');
elseif exist('results/all_experiments.mat', 'file')
    fprintf('Found original results file\n');
    load('results/all_experiments.mat', 'allResults', 'allEvaluations', 'comparisonTable');
else
    error('No results file found. Please run run_experiments or run_experiments_optimized first.');
end

scenarios = {'scenario1', 'scenario2', 'scenario3'};
scenarioNames = {'Test 1: Day 1', 'Test 2: Day 1→2 (Realistic)', 'Test 3: Combined'};
scenarioShort = {'Day 1', 'Day 1→2', 'Combined'};
modalities = {'accel', 'gyro', 'combined'};
modalityNames = {'Accelerometer', 'Gyroscope', 'Combined'};
colors = [0.2, 0.4, 0.8; 0.8, 0.2, 0.2; 0.2, 0.8, 0.2];

% Convert cell array format to struct format if needed (for optimized version)
if iscell(allResults)
    fprintf('Converting optimized results format...\n');
    tempResults = struct();
    tempEvaluations = struct();
    for s = 1:length(scenarios)
        for m = 1:length(modalities)
            resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
            tempResults.(resultName) = allResults{s, m};
            tempEvaluations.(resultName) = allEvaluations{s, m};
        end
    end
    allResults = tempResults;
    allEvaluations = tempEvaluations;
    fprintf('Conversion complete\n');
end

%% Figure 1: Accuracy Comparison Across Scenarios and Modalities
fprintf('Generating accuracy comparison plot...\n');

figure('Position', [100, 100, 1200, 600]);

% Collect data
accuracyData = zeros(length(scenarios), length(modalities));
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        accuracyData(s, m) = allEvaluations.(resultName).accuracy;
    end
end

% Create grouped bar chart
bar(accuracyData);
set(gca, 'XTickLabel', scenarioShort);
xlabel('Testing Scenario', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Test Accuracy (%)', 'FontSize', 13, 'FontWeight', 'bold');
title('Test Accuracy Comparison: Scenarios vs Modalities', 'FontSize', 15, 'FontWeight', 'bold');
legend(modalityNames, 'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 11);
grid on;
ylim([0, 100]);

% Add value labels on bars
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        text(s + (m-2)*0.25, accuracyData(s, m) + 2, sprintf('%.1f%%', accuracyData(s, m)), ...
            'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
    end
end

saveas(gcf, 'results/comparison_accuracy.png');
fprintf('✓ Saved comparison_accuracy.png\n');
close(gcf);

%% Figure 2: EER Comparison (Lower is Better)
fprintf('Generating EER comparison plot...\n');

figure('Position', [100, 100, 1200, 600]);

% Collect EER data
eerData = zeros(length(scenarios), length(modalities));
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eerData(s, m) = allEvaluations.(resultName).EER;
    end
end

% Create grouped bar chart
bar(eerData);
set(gca, 'XTickLabel', scenarioShort);
xlabel('Testing Scenario', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Equal Error Rate - EER (%)', 'FontSize', 13, 'FontWeight', 'bold');
title('EER Comparison: Scenarios vs Modalities (Lower is Better)', 'FontSize', 15, 'FontWeight', 'bold');
legend(modalityNames, 'Location', 'northeast', 'FontSize', 11);
grid on;

% Add value labels on bars
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        text(s + (m-2)*0.25, eerData(s, m) + 0.5, sprintf('%.2f%%', eerData(s, m)), ...
            'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
    end
end

% Add reference lines for quality levels
yline(5, '--r', 'EER < 5%: Excellent', 'LineWidth', 1.5, 'FontSize', 10, 'Color', [0, 0.6, 0]);
yline(10, '--', 'EER < 10%: Good', 'LineWidth', 1.5, 'FontSize', 10, 'Color', [0.8, 0.6, 0]);

saveas(gcf, 'results/comparison_eer.png');
fprintf('✓ Saved comparison_eer.png\n');
close(gcf);

%% Figure 3: FAR/FRR Curves for Each Scenario
fprintf('Generating FAR/FRR curves...\n');

for s = 1:length(scenarios)
    figure('Position', [100, 100, 1400, 500]);
    
    for m = 1:length(modalities)
        subplot(1, 3, m);
        
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eval = allEvaluations.(resultName);
        
        % Plot FAR and FRR
        plot(eval.thresholds, eval.FAR_values * 100, 'r-', 'LineWidth', 2, 'DisplayName', 'FAR');
        hold on;
        plot(eval.thresholds, eval.FRR_values * 100, 'b-', 'LineWidth', 2, 'DisplayName', 'FRR');
        
        % Mark EER point
        plot(eval.EER_threshold, eval.EER, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'g', ...
            'DisplayName', sprintf('EER = %.2f%%', eval.EER));
        
        xlabel('Decision Threshold', 'FontSize', 11);
        ylabel('Error Rate (%)', 'FontSize', 11);
        title(sprintf('%s', modalityNames{m}), 'FontSize', 12, 'FontWeight', 'bold');
        legend('Location', 'best', 'FontSize', 9);
        grid on;
        xlim([0, 1]);
        hold off;
    end
    
    sgtitle(sprintf('FAR and FRR vs Threshold - %s', scenarioNames{s}), ...
        'FontSize', 14, 'FontWeight', 'bold');
    
    saveas(gcf, sprintf('results/far_frr_%s.png', scenarios{s}));
    fprintf('✓ Saved far_frr_%s.png\n', scenarios{s});
    close(gcf);
end

%% Figure 4: Modality Comparison (All Metrics)
fprintf('Generating comprehensive modality comparison...\n');

figure('Position', [100, 100, 1400, 800]);

% Subplot 1: Accuracy by Modality
subplot(2, 2, 1);
modalityAccuracy = zeros(length(modalities), length(scenarios));
for m = 1:length(modalities)
    for s = 1:length(scenarios)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        modalityAccuracy(m, s) = allEvaluations.(resultName).accuracy;
    end
end
bar(modalityAccuracy);
set(gca, 'XTickLabel', modalityNames);
ylabel('Accuracy (%)', 'FontSize', 11);
title('Test Accuracy by Modality', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarioShort, 'FontSize', 9);
grid on;

% Subplot 2: EER by Modality
subplot(2, 2, 2);
modalityEER = zeros(length(modalities), length(scenarios));
for m = 1:length(modalities)
    for s = 1:length(scenarios)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        modalityEER(m, s) = allEvaluations.(resultName).EER;
    end
end
bar(modalityEER);
set(gca, 'XTickLabel', modalityNames);
ylabel('EER (%)', 'FontSize', 11);
title('EER by Modality (Lower is Better)', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarioShort, 'FontSize', 9);
grid on;

% Subplot 3: Average FAR by Modality
subplot(2, 2, 3);
modalityFAR = zeros(length(modalities), length(scenarios));
for m = 1:length(modalities)
    for s = 1:length(scenarios)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        modalityFAR(m, s) = mean(allEvaluations.(resultName).perUserFAR);
    end
end
bar(modalityFAR);
set(gca, 'XTickLabel', modalityNames);
ylabel('Average FAR (%)', 'FontSize', 11);
title('False Acceptance Rate by Modality', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarioShort, 'FontSize', 9);
grid on;

% Subplot 4: Average FRR by Modality
subplot(2, 2, 4);
modalityFRR = zeros(length(modalities), length(scenarios));
for m = 1:length(modalities)
    for s = 1:length(scenarios)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        modalityFRR(m, s) = mean(allEvaluations.(resultName).perUserFRR);
    end
end
bar(modalityFRR);
set(gca, 'XTickLabel', modalityNames);
ylabel('Average FRR (%)', 'FontSize', 11);
title('False Rejection Rate by Modality', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarioShort, 'FontSize', 9);
grid on;

sgtitle('Comprehensive Modality Comparison', 'FontSize', 15, 'FontWeight', 'bold');

saveas(gcf, 'results/modality_comparison.png');
fprintf('✓ Saved modality_comparison.png\n');
close(gcf);

%% Figure 5: Confusion Matrices for Most Realistic Scenario
fprintf('Generating confusion matrices for Scenario 2 (Most Realistic)...\n');

figure('Position', [100, 100, 1400, 450]);

for m = 1:length(modalities)
    subplot(1, 3, m);
    
    resultName = sprintf('scenario2_%s', modalities{m});
    eval = allEvaluations.(resultName);
    model = allResults.(resultName);
    
    confChart = confusionchart(eval.confusionMatrix, model.uniqueUsers);
    confChart.Title = modalityNames{m};
    confChart.XLabel = 'Predicted User';
    confChart.YLabel = 'True User';
end

sgtitle('Confusion Matrices - Scenario 2: Day 1→Day 2 (Most Realistic)', ...
    'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, 'results/confusion_matrices_scenario2.png');
fprintf('✓ Saved confusion_matrices_scenario2.png\n');
close(gcf);

%% Figure 6: Performance Degradation (Scenario 2)
fprintf('Generating performance degradation analysis...\n');

figure('Position', [100, 100, 1000, 600]);

degradationData = zeros(1, length(modalities));
for m = 1:length(modalities)
    resultName = sprintf('scenario2_%s', modalities{m});
    model = allResults.(resultName);
    if isfield(model, 'degradation')
        degradationData(m) = model.degradation;
    end
end

bar(degradationData);
set(gca, 'XTickLabel', modalityNames);
ylabel('Performance Degradation (%)', 'FontSize', 12);
xlabel('Modality', 'FontSize', 12);
title('Performance Degradation: Day 1 → Day 2', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% Add value labels
for m = 1:length(modalities)
    text(m, degradationData(m) + 0.5, sprintf('%.2f%%', degradationData(m)), ...
        'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
end

% Add interpretation
if max(degradationData) < 5
    text(2, max(degradationData) + 2, '✓ Stable behavior across days', ...
        'HorizontalAlignment', 'center', 'FontSize', 11, 'Color', [0, 0.6, 0], 'FontWeight', 'bold');
else
    text(2, max(degradationData) + 2, '⚠ Significant behavioral variation', ...
        'HorizontalAlignment', 'center', 'FontSize', 11, 'Color', [0.8, 0.2, 0], 'FontWeight', 'bold');
end

saveas(gcf, 'results/performance_degradation.png');
fprintf('✓ Saved performance_degradation.png\n');
close(gcf);

%% Figure 7: TAR vs FAR Curves (ROC-style)
fprintf('Generating TAR vs FAR curves...\n');

figure('Position', [100, 100, 1400, 900]);

plotIdx = 1;
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        subplot(3, 3, plotIdx);
        
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eval = allEvaluations.(resultName);
        
        % Plot TAR vs FAR
        plot(eval.FAR_values * 100, eval.TAR_values * 100, 'b-', 'LineWidth', 2);
        hold on;
        
        % Mark EER point
        eerIdx = find(abs(eval.FAR_values - eval.FRR_values) == min(abs(eval.FAR_values - eval.FRR_values)), 1);
        plot(eval.FAR_values(eerIdx) * 100, eval.TAR_values(eerIdx) * 100, 'ro', ...
            'MarkerSize', 8, 'MarkerFaceColor', 'r');
        
        xlabel('FAR (%)', 'FontSize', 10);
        ylabel('TAR (%)', 'FontSize', 10);
        title(sprintf('%s - %s', scenarioShort{s}, modalityNames{m}), 'FontSize', 11);
        grid on;
        xlim([0, 100]);
        ylim([0, 100]);
        hold off;
        
        plotIdx = plotIdx + 1;
    end
end

sgtitle('True Acceptance Rate (TAR) vs False Acceptance Rate (FAR)', ...
    'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, 'results/tar_far_all.png');
fprintf('✓ Saved tar_far_all.png\n');
close(gcf);

%% Summary
fprintf('\n============================================================\n');
fprintf('VISUALIZATION COMPLETE\n');
fprintf('============================================================\n');
fprintf('Generated plots:\n');
fprintf('  1. comparison_accuracy.png - Accuracy across scenarios\n');
fprintf('  2. comparison_eer.png - EER comparison\n');
fprintf('  3. far_frr_scenario1.png - FAR/FRR for Scenario 1\n');
fprintf('  4. far_frr_scenario2.png - FAR/FRR for Scenario 2\n');
fprintf('  5. far_frr_scenario3.png - FAR/FRR for Scenario 3\n');
fprintf('  6. modality_comparison.png - Comprehensive modality analysis\n');
fprintf('  7. confusion_matrices_scenario2.png - Confusion matrices\n');
fprintf('  8. performance_degradation.png - Day-to-day stability\n');
fprintf('  9. tar_far_all.png - ROC-style curves for all\n');
fprintf('\nAll visualizations saved to results/ folder\n');
fprintf('============================================================\n\n');

fprintf('REPORT RECOMMENDATIONS:\n');
fprintf('→ Include comparison_accuracy.png and comparison_eer.png in results section\n');
fprintf('→ Use far_frr_scenario2.png to discuss most realistic scenario\n');
fprintf('→ Include modality_comparison.png to justify sensor choice\n');
fprintf('→ Use performance_degradation.png to discuss temporal stability\n');
fprintf('→ Include confusion_matrices_scenario2.png for per-user analysis\n\n');

