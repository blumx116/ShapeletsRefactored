clearvars;

OVERWRITE_DEFAULT_PLOT_TEXT = 1;

% Load results from matlab 
load('Ben_UCR_Results.mat');
load('Ben_UCR_CV_Results.mat');

% Remove columns with 'NaN' entries
master_accuracy_columns(incomplete_datasets) = [];
master_accuracy_table(:,incomplete_datasets) = [];

%CV_master_accuracy_columns(CV_incomplete_datasets) = [];
%CV_master_accuracy_table(:,CV_incomplete_datasets) = [];

%% Specify baseline and test methods to compare
% Start with normalized vs. unnormalized
baseline_method_name{1} = 'euclidean_normed_NOCID';
test_method_name{1} = 'euclidean_unnormed_NOCID';

% Next do CID vs. no CID (euclidean)
baseline_method_name{2} = 'euclidean_normed_NOCID';
test_method_name{2} = 'euclidean_normed_CID';

baseline_method_name{3} = 'euclidean_unnormed_NOCID';
test_method_name{3} = 'euclidean_unnormed_CID';

% Next do euclidean vs. manhattan (no CID)
baseline_method_name{4} = 'euclidean_normed_NOCID';
test_method_name{4} = 'manhattan_normed_NOCID';

baseline_method_name{5} = 'euclidean_unnormed_NOCID';
test_method_name{5} = 'manhattan_unnormed_NOCID';

% Next do correlation vs. euclidean (no CID)
baseline_method_name{6} = 'euclidean_unnormed_NOCID';
test_method_name{6} = 'correlation_unnormed_NOCID';

baseline_method_name{7} = 'euclidean_normed_NOCID';
test_method_name{7} = 'correlation_unnormed_NOCID';



%% Plot accuracies for actual accuracies
for k = 1:1%7
    %% Set up strings for plot printing 
    baseline_method_name_printable = strrep(baseline_method_name{k}, '_', '\_');
    test_method_name_printable = strrep(test_method_name{k}, '_', '\_');

    %% Extract actual accuracies
    % Find row indexes for each method
    baseline_method_name_match = false(size(master_accuracy_rows));
    test_method_name_match = false(size(master_accuracy_rows));

    for i = 1:size(master_accuracy_rows)
        baseline_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
            baseline_method_name{k});
        test_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
            test_method_name{k});
    end

    baseline_method_row_index = find(baseline_method_name_match == 1);
    test_method_row_index = find(test_method_name_match == 1);

    % Extract classification accuracies
    baseline_method_classifications = master_accuracy_table(baseline_method_row_index,:);
    test_method_classifications = master_accuracy_table(test_method_row_index,:);

    % Divide both my 100 to change percent to decimal
    baseline_method_classifications = baseline_method_classifications/100;
    test_method_classifications = test_method_classifications/100;


    %% Extract predicted accuracies (from two-fold CV training)
    % Row indexes for predicted accuracies
    CV_baseline_method_name_match = false(size(CV_master_accuracy_rows));
    CV_test_method_name_match = false(size(CV_master_accuracy_rows));

    for i = 1:size(CV_master_accuracy_rows)
        CV_baseline_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
            baseline_method_name{k});
        CV_test_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
            test_method_name{k});
    end

    CV_baseline_method_row_index = find(CV_baseline_method_name_match == 1);
    CV_test_method_row_index = find(CV_test_method_name_match == 1);

    % Extract prediction classification accuracies
    CV_baseline_method_classifications = CV_master_accuracy_table(CV_baseline_method_row_index,:);
    CV_test_method_classifications = CV_master_accuracy_table(CV_test_method_row_index,:);

    % Divide both my 100 to change percent to decimal
    CV_baseline_method_classifications = CV_baseline_method_classifications/100;
    CV_test_method_classifications = CV_test_method_classifications/100;

    %% Compute expected and actual ratios

    baseline_method_predicted_classification = zeros(size(master_accuracy_columns));
    test_method_predicted_classification = zeros(size(master_accuracy_columns));
    expected_ratios = zeros(size(master_accuracy_columns));
    
    % Compute expected ratios
    for j = 1:size(master_accuracy_columns,2)
        dataset_name = master_accuracy_columns{j};
        
        dataset_regexp = [dataset_name, '_CV'];
        dataset_matches = regexp(CV_master_accuracy_columns, dataset_regexp, 'match');
        dataset_indexes = find(~cellfun(@isempty,dataset_matches));

        if (isempty(dataset_indexes))
            disp(['Dataset CVs incomplete:  ' dataset_name])
            test_method_predicted_classification(j) = -1;
            baseline_method_predicted_classification(j) = -1;
            expected_ratios(j) = -1;
        else
            test_method_predicted_classification(j) = mean(CV_master_accuracy_table(test_method_row_index,dataset_indexes));
            baseline_method_predicted_classification(j) = mean(CV_master_accuracy_table(baseline_method_row_index,dataset_indexes));
            expected_ratios(j) = test_method_predicted_classification(j) / baseline_method_predicted_classification(j);
            
        end
    end

    % Compute actual ratios
    actual_ratios = test_method_classifications ./ baseline_method_classifications;
    
    % Remove ratios that are missing data...
    remove_me_indexes = expected_ratios == -1;
    expected_ratios(remove_me_indexes) = [];
    actual_ratios(remove_me_indexes) = [];

    %% Plot predicted classification accuracies
    % Set up figure
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
%     expected_ratios = [1.3 1.2 1.05 0.85 0.7 1.2 1.13];
%     actual_ratios = [1.1 1.4 0.9 0.7 1.43 0.9 1.1];
    scatter(expected_ratios, actual_ratios, 'b', 'filled');

    % Set x and y limits and tick labels
    xlim([0.5 1.5]);
    xticks(0.5:0.1:1.5);
    xticklabels({'0.5', '', '', '', '', '1', '', '', '', '', '1.5'});

    ylim([0.5 1.5]);
    yticks(0.5:0.1:1.5);
    yticklabels({'0.5', '', '', '', '', '1', '', '', '', '', '1.5'});

    % Set axes labels and title
    if (OVERWRITE_DEFAULT_PLOT_TEXT)
        xlabel(['Expected Ratio (no normalization vs. z-normalization)'])
        ylabel(['Actual Ratio (no normalization vs. z-normalization)'])
        title(['Accuracy Ratios (no normalization vs. z-normalization)'])
    else
        xlabel(['Expected Ratio (' test_method_name_printable ' vs. ' baseline_method_name_printable ')'])
        ylabel(['Actual Ratio (' test_method_name_printable ' vs. ' baseline_method_name_printable ')'])
        title(['Accuracy Ratio (' test_method_name_printable ' vs. ' baseline_method_name_printable ')'])
    end
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










    %% Plot actual classification accuracies
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
    
    % Inserted for AAAI18 paper:
    if (k == 1)
        scatter([0.7101 0.8170], [0.4580 0.4130], 100, 'r')
    end

    % Set x and y limits and tick labels
    xlim([0 1]);
    xticks(0:0.1:1);
    xticklabels({'0', '', '', '', '', '0.5', '', '', '', '', '1'});

    ylim([0 1]);
    yticks(0:0.1:1);
    yticklabels({'0', '', '', '', '', '0.5', '', '', '', '', '1'});

    % Set axes labels and title
    if (OVERWRITE_DEFAULT_PLOT_TEXT)
        xlabel(['Accuracy without z-normalization'])
        ylabel(['Accuracy with z-normalization'])
        title(['Classification Accuracy Comparison: z-normalized data vs. raw data'])
    else
        xlabel([test_method_name_printable ' Method Accuracy'])
        ylabel([baseline_method_name_printable ' Method Accuracy'])
        title(['Classification Accuracy Comparison: ' test_method_name_printable ' vs. ' ...
            baseline_method_name_printable])
    end

    % Bring axes properties to the front so they're in front of the fill
    ax = gca;

    ax.Layer= 'top';
    ax.Box = 'on';

    % Label clearly where each algorithm is better
    if (OVERWRITE_DEFAULT_PLOT_TEXT)
        text(0.45, 0.2, 'In this area,', 'FontSize', 12)
        text(0.45, 0.15, ['z-normalization reduced accuracy'], 'FontSize', 12)

        text(0.1, 0.8, 'In this area,', 'FontSize', 12)
        text(0.1, 0.75, ['z-normalization improved accuracy'], 'FontSize', 12)
    else
        text(0.7, 0.2, 'In this area,', 'FontSize', 12)
        text(0.7, 0.15, [test_method_name_printable ' algorithm is better'], 'FontSize', 12)

        text(0.1, 0.8, 'In this area,', 'FontSize', 12)
        text(0.1, 0.75, [baseline_method_name_printable ' algorithm is better'], 'FontSize', 12)
    end
    hold off;

    % Find datasets where the test method performs better
    accuracy_improvement = test_method_classifications - baseline_method_classifications;
    datasets_improved = find(accuracy_improvement > 0);
    
    [sorted_accuracy_improvement, sort_index_dataset] = sort(accuracy_improvement);
    sorted_accuracy_improvement_names = master_accuracy_columns(sort_index_dataset);
    
    num_datasets_improved(k,1) = size(datasets_improved,2);
    
    % Calculate TP,FP,FN, and TN for datasets
    Accuracy_Prediction_Errors = [actual_ratios; expected_ratios];
    num_TPs = 0;
    num_FPs = 0;
    num_FNs = 0;
    num_TNs = 0;
    
    for i = 1:size(expected_ratios,2)
       if (expected_ratios(i) > 1)
           if (actual_ratios(i) > 1)
               num_TPs = num_TPs + 1;
           else
               num_FPs = num_FPs + 1;
           end
       else
           if (actual_ratios(i) > 1)
               num_FNs = num_FNs + 1;
           else
               num_TNs = num_TNs + 1;
           end
       end
    end
    
    %% Experimental plots (not included in the paper)
%     % Create plot for accuracies with each method separate and choosing
%     % between the two
%     
%     figure;
%     hold on;
%     
%     box1 = test_method_classifications';
%     box2 = baseline_method_classifications';
%     
%     %Make box3 (Using expected ratio to pick the better method, but using
%     %the actual classification accuracy)
%     test_method_predicted_better = find(expected_ratios > 1);
%     baseline_method_predicted_better = find(expected_ratios <= 1);
%     
%     box3 = zeros(size(box1));
%     box3(test_method_predicted_better) = test_method_classifications(test_method_predicted_better);
%     box3(baseline_method_predicted_better) = baseline_method_classifications(baseline_method_predicted_better);
%     
%     % There are a couple of NaN entries the Expected Ratio due to a bug in
%     % FastShapelets (not sure why yet), so eliminate those for now...
%     box1(box3 == 0) = [];
%     box2(box3 == 0) = [];
%     box3(box3 == 0) = [];
%     
%     x_boxplot_vals = [1; 2; 3];
%     y_boxplot_vals = [box1 box2 box3];
%     
%     boxplot(y_boxplot_vals, x_boxplot_vals, 'Notch', 'on')
%     
%     %xticklabels({'Normalized \\Data', 'Unnormalized Data', 'Choice of normalization based on Expected Ratio'});
%     set(gca, 'xticklabel', []) %Remove tick labels
%     xTicks = get(gca, 'xtick');
%     yTicks = get(gca, 'ytick');
%     
%     minY = min(yTicks);
%     VerticalOffset = 0.6;
%     HorizontalOffset = 0.2;
%     
%     text(1, 0.05,{'Normalized', 'Data'}, 'HorizontalAlignment', 'center');
%     text(2, 0.05,{'Unnormalized', 'Data'}, 'HorizontalAlignment', 'center');
%     text(3, 0.05,{'Choice of Normalization', 'Based on Expected Ratio'}, 'HorizontalAlignment', 'center');
%     
%     hold off;
%     
%     % Try a 2 numberline plot with increasing/decreasing (or TP,FP,FN,TN)
%     figure;
%     hold on
%     
%     scatter(ones(size(box1)), box1)
%     scatter(2*ones(size(box3)), box3)
%     
%     xlim([0.8 2.2]);
%     xticks([1 2]);
%     xticklabels({'0','1'});
%     
%     for i = 1:size(box1,1)
%         if (abs(box1(i) - box3(i)) < 10e-20)
%             line([1,2],[box1(i),box3(i)], 'Color', 'b', 'LineStyle', '--')
%         else
%             if (box1(i) > box3(i))
%                 line([1,2],[box1(i),box3(i)], 'Color', 'r', 'LineStyle', '--')
%             else
%                 line([1,2],[box1(i),box3(i)], 'Color', 'g', 'LineStyle', '--')
%             end
%         end
%     end
% 
%     % Calculate mean and median changes in accuracy
%     increases = [];
%     decreases = [];
%     for i = 1:size(box1,1)
%         if (abs(box1(i) - box3(i)) > 10e-20)
%             if (box1(i) > box3(i))
%                 decreases = [decreases box3(i) - box1(i)];
%             else
%                 increases = [increases box3(i) - box1(i)];
%             end
%         end
%     end
%     
%     mean_increases = sum(increases)/num_TPs;
%     mean_decreases = sum(decreases)/num_FPs;
%     median_increases = median(increases);
%     median_decreases = median(decreases);
%     
end

%% Print datasets by type

TP_Datasets = {};
FP_Datasets = {};
FN_Datasets = {};
TN_Datasets = {};

for i = 1:size(expected_ratios,2)
   if (expected_ratios(i) > 1)
       if (actual_ratios(i) > 1)
           TP_Datasets = [TP_Datasets; [master_accuracy_columns(i) round(100*(test_method_classifications(i) - baseline_method_classifications(i)),2)]];
       else
           FP_Datasets = [FP_Datasets; [master_accuracy_columns(i) round(100*(test_method_classifications(i) - baseline_method_classifications(i)),2)]];
       end
   else
       if (actual_ratios(i) > 1)
           FN_Datasets = [FN_Datasets; [master_accuracy_columns(i) round(100*(test_method_classifications(i) - baseline_method_classifications(i)),2)]];
       else
           TN_Datasets = [TN_Datasets; [master_accuracy_columns(i) round(100*(test_method_classifications(i) - baseline_method_classifications(i)),2)]];
       end
   end
end


% %% Find different in performance in accuracy by category
% TP_Indexes = [];
% FP_Indexes = [];
% FN_Indexes = [];
% TN_Indexes = [];
% 
% for i = 1:size(expected_ratios,2)
%    if (expected_ratios(i) > 1)
%        if (actual_ratios(i) > 1)
%            TP_Indexes = [TP_Indexes; i];
%        else
%            FP_Indexes = [FP_Indexes; i];
%        end
%    else
%        if (actual_ratios(i) > 1)
%            FN_Indexes = [FN_Indexes; i];
%        else
%            TN_Indexes = [TN_Indexes; i];
%        end
%    end
% end



% 
% %% Plot Accuracy Ratios
% for k = 1%1:7
%     %% Set up strings for plot printing and find row indexes for each method
%     % Printable strings
%     baseline_method_name_printable = strrep(baseline_method_name{k}, '_', '\_');
%     test_method_name_printable = strrep(test_method_name{k}, '_', '\_');
% 
%     % Row indexes for actual accuracies
%     baseline_method_name_match = false(size(master_accuracy_rows));
%     test_method_name_match = false(size(master_accuracy_rows));
% 
%     for i = 1:size(master_accuracy_rows)
%         baseline_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
%             baseline_method_name{k});
%         test_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
%             test_method_name{k});
%     end
% 
%     baseline_method_row_index = find(baseline_method_name_match == 1);
%     test_method_row_index = find(test_method_name_match == 1);
% 
%     % Row indexes for predicted accuracies
%     CV_baseline_method_name_match = false(size(CV_master_accuracy_rows));
%     CV_test_method_name_match = false(size(CV_master_accuracy_rows));
% 
%     for i = 1:size(CV_master_accuracy_rows)
%         CV_baseline_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
%             baseline_method_name{k});
%         CV_test_method_name_match(i) = strcmp(master_accuracy_rows{i}, ...
%             test_method_name{k});
%     end
% 
%     CV_baseline_method_row_index = find(CV_baseline_method_name_match == 1);
%     CV_test_method_row_index = find(CV_test_method_name_match == 1);
% 
%     %% Plot classification accuracies
%     CV_baseline_method_classifications = CV_master_accuracy_table(CV_baseline_method_row_index,:);
%     CV_test_method_classifications = CV_master_accuracy_table(CV_test_method_row_index,:);
% 
% 
% 
% 
% 
% 
% 
% 
%     % Set up figure
%     figure;
%     hold on;
% 
%     % Shade in NE and SW regions for true positives and true negatives
%     square_NE_x = [1 1 1.5 1.5];
%     square_NE_y = [1 1.5 1.5 1];
%     fill(square_NE_x, square_NE_y, [250,212,180]/255)
% 
%     square_SW_x = [0.5 0.5 1 1];
%     square_SW_y = [0.5 1 1 0.5];
%     fill(square_SW_x, square_SW_y, [250,212,180]/255)
% 
%     % Sample 'dummy' data
%     expected_ratios = [1.3 1.2 1.05 0.85 0.7 1.2 1.13];
%     actual_ratios = [1.1 1.4 0.9 0.7 1.43 0.9 1.1];
%     scatter(expected_ratios, actual_ratios, 'b', 'filled');
% 
%     % Set x and y limits and tick labels
%     xlim([0.5 1.5]);
%     xticks(0.5:0.1:1.5);
%     xticklabels({'0.5', '', '', '', '', '1', '', '', '', '', '1.5'});
% 
%     ylim([0.5 1.5]);
%     yticks(0.5:0.1:1.5);
%     yticklabels({'0.5', '', '', '', '', '1', '', '', '', '', '1.5'});
% 
%     % Set axes labels and title
%     xlabel('Expected Ratio (Test vs. Baseline)')
%     ylabel('Actual Ratio (Test vs. Baseline)')
%     title('Accuracy Ratio')
% 
%     % Bring axes properties to the front so they're in front of the fill
%     ax = gca;
% 
%     ax.Layer= 'top';
%     ax.Box = 'on';
% 
%     % Label true positives, false positives, false negatives, and true
%     % negatives
%     text(1.3, 1.3, 'TP', 'FontSize', 12)
%     text(1.3, 0.7, 'FP', 'FontSize', 12)
% 
%     text(0.7, 1.3, 'FN', 'FontSize', 12)
%     text(0.7, 0.7, 'TN', 'FontSize', 12)
%     hold off;
% end