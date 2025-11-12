function helpers_variability_plot()
%% HELPERS_VARIABILITY_PLOT - Visualize user feature variability
% =========================================================================
% This function analyzes and visualizes how features vary across different
% users, which is crucial for understanding the discriminative power of
% behavioral biometrics.
%
% Visualizations:
%   1. PCA scatter plot: 2D projection showing user clusters
%   2. Boxplots: Distribution of top discriminative features per user
%
% Outputs:
%   - results/PCA_scatter.png
%   - results/feature_boxplots.png
%
% Reference: [6] Jolliffe & Cadima, 2016 - Principal Component Analysis: A Review
% =========================================================================

    fprintf('Loading feature data...\n');
    load('results/featuresTable.mat', 'allFeatures', 'allLabels', 'featureNames');
    
    uniqueUsers = unique(allLabels);
    numUsers = length(uniqueUsers);
    
    fprintf('Number of users: %d\n', numUsers);
    fprintf('Number of features: %d\n', size(allFeatures, 2));
    
    %% PCA Visualization
    fprintf('\nPerforming PCA for visualization...\n');
    
    % Standardize features
    X_std = (allFeatures - mean(allFeatures)) ./ std(allFeatures);
    
    % Apply PCA
    [coeff, score, latent, ~, explained] = pca(X_std);
    
    fprintf('PC1 explains %.2f%% of variance\n', explained(1));
    fprintf('PC2 explains %.2f%% of variance\n', explained(2));
    fprintf('Total variance explained by PC1+PC2: %.2f%%\n', sum(explained(1:2)));
    
    % Create color map for users
    colors = lines(numUsers);
    
    % Plot PCA scatter
    figure('Position', [100, 100, 1000, 700]);
    hold on;
    
    for i = 1:numUsers
        userID = uniqueUsers(i);
        userMask = (allLabels == userID);
        scatter(score(userMask, 1), score(userMask, 2), 50, ...
                colors(i, :), 'filled', 'MarkerFaceAlpha', 0.6, ...
                'DisplayName', sprintf('User %d', userID));
    end
    
    hold off;
    xlabel(sprintf('PC1 (%.2f%% variance)', explained(1)), 'FontSize', 12);
    ylabel(sprintf('PC2 (%.2f%% variance)', explained(2)), 'FontSize', 12);
    title('PCA: User Feature Variability', 'FontSize', 14, 'FontWeight', 'bold');
    legend('Location', 'bestoutside', 'FontSize', 10);
    grid on;
    
    saveas(gcf, 'results/PCA_scatter.png');
    fprintf('✓ Saved PCA_scatter.png\n');
    close(gcf);
    
    %% Feature Importance for Boxplots
    fprintf('\nComputing feature importance for boxplots...\n');
    
    % Compute F-statistics for each feature
    numFeatures = size(allFeatures, 2);
    fScores = zeros(numFeatures, 1);
    
    for f = 1:numFeatures
        try
            [~, ~, stats] = anova1(allFeatures(:, f), allLabels, 'off');
            fScores(f) = stats.F;
        catch
            fScores(f) = 0;
        end
    end
    
    % Select top 6 features
    [~, topIdx] = sort(fScores, 'descend');
    topFeatures = topIdx(1:min(6, numFeatures));
    
    fprintf('Top 6 discriminative features:\n');
    for i = 1:length(topFeatures)
        fprintf('  %d. %s (F=%.2f)\n', i, featureNames{topFeatures(i)}, fScores(topFeatures(i)));
    end
    
    %% Boxplots
    fprintf('\nGenerating boxplots...\n');
    
    figure('Position', [100, 100, 1400, 900]);
    
    for i = 1:length(topFeatures)
        subplot(2, 3, i);
        
        featIdx = topFeatures(i);
        featData = allFeatures(:, featIdx);
        
        % Prepare data for boxplot
        boxData = [];
        boxGroups = [];
        for u = 1:numUsers
            userID = uniqueUsers(u);
            userMask = (allLabels == userID);
            userData = featData(userMask);
            boxData = [boxData; userData];
            boxGroups = [boxGroups; repmat(userID, length(userData), 1)];
        end
        
        boxplot(boxData, boxGroups, 'Colors', colors, 'Symbol', '');
        title(featureNames{featIdx}, 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('User ID', 'FontSize', 10);
        ylabel('Feature Value', 'FontSize', 10);
        grid on;
    end
    
    sgtitle('Feature Distributions Across Users (Top 6 Discriminative Features)', ...
            'FontSize', 14, 'FontWeight', 'bold');
    
    saveas(gcf, 'results/feature_boxplots.png');
    fprintf('✓ Saved feature_boxplots.png\n');
    close(gcf);
    
    %% Feature Statistics
    fprintf('\n--- Feature Variability Analysis ---\n');
    fprintf('Users show distinct patterns in behavioral biometrics:\n');
    
    for i = 1:min(3, length(topFeatures))
        featIdx = topFeatures(i);
        featName = featureNames{featIdx};
        
        % Compute between-user vs within-user variance
        totalVar = var(allFeatures(:, featIdx));
        
        withinVar = 0;
        for u = 1:numUsers
            userID = uniqueUsers(u);
            userMask = (allLabels == userID);
            withinVar = withinVar + var(allFeatures(userMask, featIdx));
        end
        withinVar = withinVar / numUsers;
        
        betweenVar = totalVar - withinVar;
        ratio = betweenVar / withinVar;
        
        fprintf('\n  Feature: %s\n', featName);
        fprintf('    Between-user variance: %.4f\n', betweenVar);
        fprintf('    Within-user variance: %.4f\n', withinVar);
        fprintf('    Ratio (higher = more discriminative): %.2f\n', ratio);
    end
    
    fprintf('\n✓ Variability analysis complete!\n');
end

