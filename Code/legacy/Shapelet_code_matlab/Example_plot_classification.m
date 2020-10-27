%% Plot classification accuracies
% Example of comparing classification accuracy of 2 methods
% Modeled after figure 8 in FastShapelets paper

% Start with some 'dummy' classification values for now
baseline_method_classifications = [80 65 20 37 95 93 90];
test_method_classifications = [82 60 55 47 90 95 96];

% Divide both my 100 (this will be needed for the actual data as well)
baseline_method_classifications = baseline_method_classifications/100;
test_method_classifications = test_method_classifications/100;

figure;
hold on;

% Change values to x and y for plotting clarity
x = test_method_classifications;
y = baseline_method_classifications;

% Shade in upper region
triangle_x = [0 0 1];
triangle_y = [0 1 1];
fill(triangle_x, triangle_y, [250,212,180]/255)

% Plot points
scatter(x, y, 'b', 'filled')

% Set x and y limits and tick labels
xlim([0 1]);
xticks(0:0.1:1);
xticklabels({'0', '', '', '', '', '0.5', '', '', '', '', '1'});

ylim([0 1]);
yticks(0:0.1:1);
yticklabels({'0', '', '', '', '', '0.5', '', '', '', '', '1'});

% Set axes labels and title
xlabel('Test Method Accuracy')
ylabel('Baseline Method Accuracy')
title('Classification Accuracy Comparison')

% Bring axes properties to the front so they're in front of the fill
ax = gca;

ax.Layer= 'top';
ax.Box = 'on';

% Label clearly where each algorithm is better
text(0.7, 0.2, 'In this area,', 'FontSize', 12)
text(0.7, 0.15, 'test algorithm is better', 'FontSize', 12)

text(0.1, 0.8, 'In this area,', 'FontSize', 12)
text(0.1, 0.75, 'baseline algorithm is better', 'FontSize', 12)
hold off;

%% Plot Accuracy Ratios
% Modeled after figure 11 in FastShapelets paper
figure;
hold on;

% Shade in NE and SW regions for true positives and true negatives
square_NE_x = [1 1 1.5 1.5];
square_NE_y = [1 1.5 1.5 1];
fill(square_NE_x, square_NE_y, [250,212,180]/255)

square_SW_x = [0.5 0.5 1 1];
square_SW_y = [0.5 1 1 0.5];
fill(square_SW_x, square_SW_y, [250,212,180]/255)

% Sample 'dummy' data
expected_ratios = [1.3 1.2 1.05 0.85 0.7 1.2 1.13];
actual_ratios = [1.1 1.4 0.9 0.7 1.43 0.9 1.1];
scatter(expected_ratios, actual_ratios, 'b', 'filled');

% Set x and y limits and tick labels
xlim([0.5 1.5]);
xticks(0.5:0.1:1.5);
xticklabels({'0.5', '', '', '', '', '1', '', '', '', '', '1.5'});

ylim([0.5 1.5]);
yticks(0.5:0.1:1.5);
yticklabels({'0.5', '', '', '', '', '1', '', '', '', '', '1.5'});

% Set axes labels and title
xlabel('Expected Ratio (Test vs. Baseline)')
ylabel('Actual Ratio (Test vs. Baseline)')
title('Accuracy Ratio')

% Bring axes properties to the front so they're in front of the fill
ax = gca;

ax.Layer= 'top';
ax.Box = 'on';

% Label true positives, false positives, false negatives, and true
% negatives
text(1.3, 1.3, 'TP', 'FontSize', 12)
text(1.3, 0.7, 'FP', 'FontSize', 12)

text(0.7, 1.3, 'FN', 'FontSize', 12)
text(0.7, 0.7, 'TN', 'FontSize', 12)
hold off;



