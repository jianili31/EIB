clear all
load emotion_scores_normalized.mat

% average raw scores across emotion Qs
for i = 1:4
    average_score_byVid(:, i) = (dataemotionQsreordered(:, i) +...
        dataemotionQsreordered(:, i+4) +...
        dataemotionQsreordered(:, i+8)) / 3;
end
clear i
% Result: Pro1 scores, Anti1 scores, Pro2 scores, Anti2 scores

% average raw scores across video types
% result: pro scores = 1st column, anti scores = 2nd column
for i=1:2
    average_score_pro_anti(:, i) = (average_score_byVid(:, i) +...
        average_score_byVid(:, i+2)) / 2;
end
clear i

% filter out subjects w/o neural data
load('/Users/jianili/Desktop/OIB/NeuralData/all_workspace_usefulVariables.mat', 'not_exclude')
average_score_pro_anti_neuBehav = average_score_pro_anti(not_exclude, :);

mean_pro = mean(average_score_pro_anti_neuBehav(:, 1));
mean_anti = mean(average_score_pro_anti_neuBehav(:, 2));
positive_pro = find(average_score_pro_anti_neuBehav(:, 1) > mean_pro);
negative_pro = find(average_score_pro_anti_neuBehav(:, 1) <= mean_pro);

positive_anti = find(average_score_pro_anti_neuBehav(:, 2) > mean_anti);
negative_anti = find(average_score_pro_anti_neuBehav(:, 2) <= mean_anti);

save("emotion_groups.mat", "positive_pro", "negative_pro", "positive_anti", "negative_anti")



