%% GENERATE_EER_DIAGRAM - Create comprehensive EER visualization for report
% =========================================================================
% This script generates a publication-quality EER diagram with:
%   - FAR and FRR curves with clear annotations
%   - EER point clearly marked
%   - Security vs Usability zones
%   - Quality benchmarks
%   - Conceptual explanation
%
% Specifically designed for academic reports to explain EER concept
% =========================================================================

clear all; close all; clc;

fprintf('============================================================\n');
fprintf('GENERATING ENHANCED EER DIAGRAM FOR REPORT\n');
fprintf('============================================================\n\n');

% Load experimental results
fprintf('Loading experimental results...\n');
load('results/all_experiments.mat', 'allEvaluations');

% Use Scenario 2 Combined (most realistic and important)
eval_realistic = allEvaluations.scenario2_combined;

fprintf('Creating EER diagram for Scenario 2 (Realistic) - Combined Sensors\n');
fprintf('  Accuracy: %.2f%%\n', eval_realistic.accuracy);
fprintf('  EER: %.2f%%\n', eval_realistic.EER);
fprintf('  EER Threshold: %.4f\n', eval_realistic.EER_threshold);

%% Figure 1: Detailed EER Diagram with Annotations
figure('Position', [100, 100, 1400, 800]);

% Main plot - FAR and FRR curves
plot(eval_realistic.thresholds, eval_realistic.FAR_values * 100, 'r-', 'LineWidth', 3);
hold on;
plot(eval_realistic.thresholds, eval_realistic.FRR_values * 100, 'b-', 'LineWidth', 3);

% Mark EER point with larger marker
plot(eval_realistic.EER_threshold, eval_realistic.EER, 'o', ...
    'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0, 0.8, 0], 'LineWidth', 2);

% Draw vertical line at EER threshold
line([eval_realistic.EER_threshold, eval_realistic.EER_threshold], [0, 100], ...
    'Color', [0.4, 0.4, 0.4], 'LineStyle', '--', 'LineWidth', 1.5);

% Add horizontal line at EER value
line([0, 1], [eval_realistic.EER, eval_realistic.EER], ...
    'Color', [0.4, 0.4, 0.4], 'LineStyle', '--', 'LineWidth', 1.5);

% Shade security vs usability zones
% Left zone (low threshold) - High FAR = Security Risk
patch([0, eval_realistic.EER_threshold, eval_realistic.EER_threshold, 0], ...
      [0, 0, 100, 100], [1, 0.7, 0.7], 'FaceAlpha', 0.15, 'EdgeColor', 'none');

% Right zone (high threshold) - High FRR = Usability Issue  
patch([eval_realistic.EER_threshold, 1, 1, eval_realistic.EER_threshold], ...
      [0, 0, 100, 100], [0.7, 0.7, 1], 'FaceAlpha', 0.15, 'EdgeColor', 'none');

% Add zone labels
text(eval_realistic.EER_threshold/2, 85, 'Security Risk Zone', ...
    'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', ...
    'Color', [0.8, 0, 0], 'BackgroundColor', 'w', 'EdgeColor', 'k', 'LineWidth', 1);
text(0.5, 15, '(High FAR: Impostors Accepted)', ...
    'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', [0.6, 0, 0]);

text((1 + eval_realistic.EER_threshold)/2, 85, 'Usability Issue Zone', ...
    'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', ...
    'Color', [0, 0, 0.8], 'BackgroundColor', 'w', 'EdgeColor', 'k', 'LineWidth', 1);
text(0.8, 15, '(High FRR: Genuine Users Rejected)', ...
    'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', [0, 0, 0.6]);

% EER point annotation with arrow
annotation('textarrow', [0.55, 0.48], [0.45, 0.35], ...
    'String', {sprintf('EER Point: %.2f%%', eval_realistic.EER), ...
               sprintf('Threshold: %.3f', eval_realistic.EER_threshold), ...
               '(Optimal Balance)'}, ...
    'FontSize', 13, 'FontWeight', 'bold', 'Color', [0, 0.6, 0], ...
    'LineWidth', 2, 'HeadStyle', 'cback2', 'HeadLength', 12, 'HeadWidth', 12);

% Add quality benchmark lines
yline(1, ':', 'Exceptional (<1%)', 'LineWidth', 2, 'Color', [0, 0.6, 0], ...
    'FontSize', 10, 'FontWeight', 'bold', 'LabelHorizontalAlignment', 'left');
yline(5, ':', 'Excellent (<5%)', 'LineWidth', 2, 'Color', [0.2, 0.5, 0.2], ...
    'FontSize', 10, 'FontWeight', 'bold', 'LabelHorizontalAlignment', 'left');
yline(10, ':', 'Good (<10%)', 'LineWidth', 2, 'Color', [0.8, 0.6, 0], ...
    'FontSize', 10, 'FontWeight', 'bold', 'LabelHorizontalAlignment', 'left');

% Labels and title
xlabel('Decision Threshold', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Error Rate (%)', 'FontSize', 14, 'FontWeight', 'bold');
title({'Equal Error Rate (EER) Analysis', ...
       'Scenario 2: Train Day 1 → Test Day 2 (Most Realistic)', ...
       sprintf('Combined Sensors: Accuracy = %.2f%%, EER = %.2f%%', ...
       eval_realistic.accuracy, eval_realistic.EER)}, ...
       'FontSize', 16, 'FontWeight', 'bold');

% Legend
legend({'FAR (False Acceptance Rate)', 'FRR (False Rejection Rate)', ...
        sprintf('EER = %.2f%%', eval_realistic.EER)}, ...
       'Location', 'east', 'FontSize', 12, 'FontWeight', 'bold');

grid on;
xlim([0, 1]);
ylim([0, 100]);
set(gca, 'FontSize', 11);

% Add explanatory text box
annotation('textbox', [0.15, 0.02, 0.7, 0.08], ...
    'String', sprintf(['FAR (Red): Probability system accepts impostor (Security metric) | ' ...
                       'FRR (Blue): Probability system rejects genuine user (Usability metric) | ' ...
                       'EER (Green): Point where FAR = FRR (Optimal balance point)']), ...
    'FontSize', 10, 'FontWeight', 'bold', 'EdgeColor', 'k', 'LineWidth', 1.5, ...
    'BackgroundColor', [1, 1, 0.9], 'HorizontalAlignment', 'center');

saveas(gcf, 'results/eer_diagram_detailed.png');
fprintf('✓ Saved eer_diagram_detailed.png\n');

%% Figure 2: EER Comparison Across All Experiments (Enhanced)
figure('Position', [100, 100, 1400, 700]);

scenarios = {'scenario1', 'scenario2', 'scenario3'};
scenarioNames = {'Scenario 1: Day 1', 'Scenario 2: Day 1→2', 'Scenario 3: Combined'};
modalities = {'accel', 'gyro', 'combined'};
modalityNames = {'Accelerometer', 'Gyroscope', 'Combined'};

% Collect EER data
eerData = zeros(length(scenarios), length(modalities));
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eerData(s, m) = allEvaluations.(resultName).EER;
    end
end

% Create bar chart with custom colors
b = bar(eerData);
b(1).FaceColor = [0.3, 0.5, 0.9];  % Accelerometer - blue
b(2).FaceColor = [0.9, 0.4, 0.3];  % Gyroscope - red
b(3).FaceColor = [0.3, 0.8, 0.4];  % Combined - green

set(gca, 'XTickLabel', scenarioNames);
xlabel('Testing Scenario', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Equal Error Rate - EER (%)', 'FontSize', 14, 'FontWeight', 'bold');
title({'EER Comparison: All 9 Experiments (3 Scenarios × 3 Modalities)', ...
       'Lower EER = Better Performance'}, 'FontSize', 16, 'FontWeight', 'bold');
legend(modalityNames, 'Location', 'northeast', 'FontSize', 12, 'FontWeight', 'bold');
grid on;

% Add value labels on bars
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        yPos = eerData(s, m) + max(eerData(:)) * 0.05;
        text(s + (m-2)*0.27, yPos, sprintf('%.2f%%', eerData(s, m)), ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
    end
end

% Add quality reference lines
yline(1, '--', 'Exceptional (<1%)', 'LineWidth', 2.5, 'Color', [0, 0.5, 0], ...
    'FontSize', 11, 'FontWeight', 'bold', 'LabelHorizontalAlignment', 'right');
yline(5, '--', 'Excellent (<5%)', 'LineWidth', 2.5, 'Color', [0.2, 0.6, 0.2], ...
    'FontSize', 11, 'FontWeight', 'bold', 'LabelHorizontalAlignment', 'right');
yline(10, '--', 'Good (<10%)', 'LineWidth', 2.5, 'Color', [0.8, 0.6, 0], ...
    'FontSize', 11, 'FontWeight', 'bold', 'LabelHorizontalAlignment', 'right');

% Highlight best result
[minEER, minIdx] = min(eerData(:));
[minRow, minCol] = ind2sub(size(eerData), minIdx);
hold on;
plot(minRow, eerData(minRow, minCol), '*', 'MarkerSize', 25, 'LineWidth', 3, 'Color', [1, 0.84, 0]);
text(minRow, eerData(minRow, minCol) - max(eerData(:)) * 0.08, '★ BEST', ...
    'HorizontalAlignment', 'center', 'FontSize', 13, 'FontWeight', 'bold', 'Color', [1, 0.6, 0]);

set(gca, 'FontSize', 11);
ylim([0, max(eerData(:)) * 1.2]);

saveas(gcf, 'results/eer_comparison_enhanced.png');
fprintf('✓ Saved eer_comparison_enhanced.png\n');

%% Figure 3: EER Quality Scale Visualization
figure('Position', [100, 100, 1200, 600]);

% Create quality scale
qualityLevels = {'Exceptional', 'Excellent', 'Good', 'Fair', 'Poor'};
qualityRanges = [0, 1; 1, 5; 5, 10; 10, 20; 20, 30];
qualityColors = [0, 0.8, 0; 0.2, 0.6, 0.2; 0.8, 0.6, 0; 0.9, 0.5, 0; 0.8, 0.2, 0.2];

for i = 1:length(qualityLevels)
    rectangle('Position', [0, qualityRanges(i, 1), 1, qualityRanges(i, 2) - qualityRanges(i, 1)], ...
        'FaceColor', [qualityColors(i, :), 0.3], 'EdgeColor', 'k', 'LineWidth', 2);
    text(0.5, mean(qualityRanges(i, :)), sprintf('%s\n(%g-%g%%)', qualityLevels{i}, ...
        qualityRanges(i, 1), qualityRanges(i, 2)), ...
        'HorizontalAlignment', 'center', 'FontSize', 13, 'FontWeight', 'bold');
end

% Mark project results
hold on;
projectEERs = [eval_realistic.EER, ...  % Scenario 2 combined (realistic)
               allEvaluations.scenario3_combined.EER, ...  % Best case
               allEvaluations.scenario2_accel.EER];  % Single sensor

projectLabels = {'This Study (Realistic)', 'This Study (Best)', 'Single Sensor'};
projectMarkers = {'o', 's', 'd'};
projectColors = [0, 0.7, 0; 0, 0.9, 0; 0.3, 0.6, 0.9];

for i = 1:length(projectEERs)
    plot(0.5, projectEERs(i), projectMarkers{i}, 'MarkerSize', 20, ...
        'MarkerFaceColor', projectColors(i, :), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    text(0.7, projectEERs(i), sprintf('%s: %.2f%%', projectLabels{i}, projectEERs(i)), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', projectColors(i, :));
end

% Add literature benchmarks
literature = struct('name', {'Typical Gait Systems', 'Face Recognition', 'Fingerprint'}, ...
                   'eer', {10, 5, 1.5}, ...
                   'color', {[0.6, 0.6, 0.6], [0.7, 0.5, 0.7], [0.5, 0.5, 0.9]});

for i = 1:length(literature)
    plot(0.3, literature(i).eer, 'x', 'MarkerSize', 15, ...
        'MarkerEdgeColor', literature(i).color, 'LineWidth', 3);
    text(0.15, literature(i).eer, sprintf('%s: ~%.1f%%', literature(i).name, literature(i).eer), ...
        'FontSize', 10, 'Color', literature(i).color);
end

xlim([0, 1]);
ylim([0, 30]);
set(gca, 'XTick', [], 'FontSize', 12);
ylabel('Equal Error Rate (EER) %', 'FontSize', 14, 'FontWeight', 'bold');
title({'EER Quality Scale & Project Performance', ...
       sprintf('This Project Achieves: %.2f%% (Realistic) to %.2f%% (Best)', ...
       eval_realistic.EER, allEvaluations.scenario3_combined.EER)}, ...
       'FontSize', 16, 'FontWeight', 'bold');

grid on;

saveas(gcf, 'results/eer_quality_scale.png');
fprintf('✓ Saved eer_quality_scale.png\n');

%% Figure 4: FAR vs FRR Tradeoff (3D Surface)
figure('Position', [100, 100, 1200, 700]);

% Create conceptual FAR/FRR tradeoff surface
thresholds = 0:0.01:1;
FAR_concept = 100 * (1 - thresholds).^2;  % Decreases with threshold
FRR_concept = 100 * thresholds.^2;        % Increases with threshold

subplot(2, 1, 1);
plot(thresholds, FAR_concept, 'r-', 'LineWidth', 3, 'DisplayName', 'FAR (Security Risk)');
hold on;
plot(thresholds, FRR_concept, 'b-', 'LineWidth', 3, 'DisplayName', 'FRR (Usability Issue)');
plot(thresholds, FAR_concept + FRR_concept, 'k--', 'LineWidth', 2, 'DisplayName', 'Total Error');

% Find EER point
[~, eer_idx] = min(abs(FAR_concept - FRR_concept));
eer_point = (FAR_concept(eer_idx) + FRR_concept(eer_idx)) / 2;
plot(thresholds(eer_idx), eer_point, 'o', 'MarkerSize', 18, ...
    'MarkerFaceColor', [0, 0.8, 0], 'MarkerEdgeColor', 'k', 'LineWidth', 2);

xlabel('Decision Threshold', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Error Rate (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Security vs Usability Tradeoff (Conceptual)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'north', 'FontSize', 11);
grid on;
xlim([0, 1]);

% Add annotations
text(0.2, 80, {'Low Threshold:', 'Easy to authenticate', '(Security Risk)'}, ...
    'FontSize', 10, 'Color', [0.8, 0, 0], 'FontWeight', 'bold');
text(0.7, 80, {'High Threshold:', 'Hard to authenticate', '(Usability Issue)'}, ...
    'FontSize', 10, 'Color', [0, 0, 0.8], 'FontWeight', 'bold');
text(thresholds(eer_idx), eer_point + 15, 'EER: Optimal Balance', ...
    'FontSize', 11, 'Color', [0, 0.6, 0], 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Actual project results
subplot(2, 1, 2);
plot(eval_realistic.thresholds, eval_realistic.FAR_values * 100, 'r-', 'LineWidth', 3);
hold on;
plot(eval_realistic.thresholds, eval_realistic.FRR_values * 100, 'b-', 'LineWidth', 3);
plot(eval_realistic.EER_threshold, eval_realistic.EER, 'o', 'MarkerSize', 18, ...
    'MarkerFaceColor', [0, 0.8, 0], 'MarkerEdgeColor', 'k', 'LineWidth', 2);

xlabel('Decision Threshold', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Error Rate (%)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Actual Project Results (Scenario 2: EER = %.2f%%)', eval_realistic.EER), ...
    'FontSize', 14, 'FontWeight', 'bold');
legend({'FAR', 'FRR', sprintf('EER = %.2f%%', eval_realistic.EER)}, ...
    'Location', 'east', 'FontSize', 11);
grid on;
xlim([0, 1]);

saveas(gcf, 'results/eer_tradeoff_analysis.png');
fprintf('✓ Saved eer_tradeoff_analysis.png\n');

close all;

%% Summary
fprintf('\n============================================================\n');
fprintf('EER DIAGRAM GENERATION COMPLETE\n');
fprintf('============================================================\n');
fprintf('Generated files in results/ folder:\n');
fprintf('  1. eer_diagram_detailed.png - Main annotated EER diagram\n');
fprintf('  2. eer_comparison_enhanced.png - All 9 experiments comparison\n');
fprintf('  3. eer_quality_scale.png - Quality benchmarks & literature\n');
fprintf('  4. eer_tradeoff_analysis.png - Security vs usability tradeoff\n');
fprintf('\nRECOMMENDATION FOR REPORT:\n');
fprintf('  → Use eer_diagram_detailed.png in Results section\n');
fprintf('  → Use eer_quality_scale.png in Discussion section\n');
fprintf('  → Use eer_comparison_enhanced.png to show all experiments\n');
fprintf('============================================================\n');

