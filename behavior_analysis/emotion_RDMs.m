clear all

load emotion_scores_normalized.mat

behavioral_data = dataemotionQsreordered;
N = length(ID);
pairs = [{'Like_Pro1'} {'Like_Anti1'} {'Like_Pro2'} {'Like_Anti2'} ...
    {'Bother_Pro1'} {'Bother_Anti1'} {'Bother_Pro2'} {'Bother_Anti2'} ...
    {'Experience_Pro1'} {'Experience_Anti1'} {'Experience_Pro2'} {'Experience_Anti2'}];

behavRDM.Like_Pro1 = NaN(120);
behavRDM.Like_Pro2 = NaN(120);
behavRDM.Like_Anti1 = NaN(120);
behavRDM.Like_Anti2 = NaN(120);
behavRDM.Bother_Pro1 = NaN(120);
behavRDM.Bother_Pro2 = NaN(120);
behavRDM.Bother_Anti = NaN(120);
behavRDM.Bother_Anti2 = NaN(120);
behavRDM.Experience_Pro1 = NaN(120);
behavRDM.Experience_Pro2 = NaN(120);
behavRDM.Experience_Anti1 = NaN(120);
behavRDM.Experience_Anti2 = NaN(120);

for k=1:size(behavioral_data, 2) % 1:12
    item = behavioral_data(:, k);
    item_name = pairs{k};
    for i=1:N
       for j=i:N
           eval(strcat('behavRDM.', item_name, "(j, i)", "= abs(item(i) - item(j));"));
       end
    end
end
clear i j k item item_name

%% Average behavioral differences across videos of the same stance
behavRDM.Like_Pro = (behavRDM.Like_Pro1 + behavRDM.Like_Pro2) / 2;
behavRDM.Like_Anti = (behavRDM.Like_Anti1 + behavRDM.Like_Anti2) / 2;
behavRDM.Bother_Pro = (behavRDM.Bother_Pro1 + behavRDM.Bother_Pro2) / 2;
behavRDM.Bother_Anti = (behavRDM.Bother_Anti1 + behavRDM.Bother_Anti2) / 2;
behavRDM.Experience_Pro = (behavRDM.Experience_Pro1 + behavRDM.Experience_Pro2) / 2;
behavRDM.Experience_Anti = (behavRDM.Experience_Anti1 + behavRDM.Experience_Anti2) / 2;

%% Average across emotion Qs
behavRDM.Pro = (behavRDM.Like_Pro + behavRDM.Bother_Pro + behavRDM.Experience_Pro) / 3;
behavRDM.Anti = (behavRDM.Like_Anti + behavRDM.Bother_Anti + behavRDM.Experience_Anti) / 3;


%% Build different RDMs for emotion groups
behavRDM.negative_anti = behavRDM.Anti(negative_anti, negative_anti);
behavRDM.positive_anti = behavRDM.Anti(positive_anti, positive_anti);
behavRDM.negative_pro = behavRDM.Pro(negative_pro, negative_pro);
behavRDM.positive_pro = behavRDM.Pro(positive_pro, positive_pro);

save('emotion_RDMs_UPDATED.mat', 'behavRDM');
save('emotion_RDMs_UPDATED.mat', "negative_anti", "negative_pro", "positive_anti", "positive_pro", "-append")

%% Build behavioral RDM for kmeans groups, using 12D vectors

multivariate_behavioral_RDM.kmeans_12D_group1 = zeros(48);
multivariate_behavioral_RDM.kmeans_12D_group2 = zeros(56);

% group 1
for i = 1:47
    for j = i:48
        part1 = group1(i, :);
        part2 = group1(j, :);
        multivariate_behavioral_RDM.kmeans_12D_group1(j, i) = norm(part1 - part2);
    end
end
clear i j part1 part2

% group 2
for i = 1:55
    for j = i:56
        part1 = group2(i, :);
        part2 = group2(j, :);
        multivariate_behavioral_RDM.kmeans_12D_group2(j, i) = norm(part1 - part2);
    end
end
clear i j part1 part2

%% Build behavioral RDM for kmeans groups, using 6D vectors (3 emotion Qs * 2 videos of the same stance)

multivariate_behavioral_RDM.kmeans_pro_group1 = zeros(48);
multivariate_behavioral_RDM.kmeans_6D_group2 = zeros(56);

% group 1
for i = 1:47
    for j = i:48
        part1_pro = group1(i, [1, 3, 5, 7, 9, 11]);
        part2_pro = group1(j, [1, 3, 5, 7, 9, 11]);
        part1_anti = group1(i, [2, 4, 6, 8, 10, 12]);
        part2_anti = group1(j, [2, 4, 6, 8, 10, 12]);        
        multivariate_behavioral_RDM.kmeans_pro_group1(j, i) = norm(part1_pro - part2_pro);
        multivariate_behavioral_RDM.kmeans_anti_group1(j, i) = norm(part1_anti - part2_anti);        
    end
end
clear i j part* 

multivariate_behavioral_RDM.kmeans_pro_group1 = [multivariate_behavioral_RDM.kmeans_pro_group1, zeros(48, 1)];
multivariate_behavioral_RDM.kmeans_anti_group1 = [multivariate_behavioral_RDM.kmeans_anti_group1, zeros(48, 1)];
% group 2
for i = 1:55
    for j = i:56
        part1_pro = group2(i, [1, 3, 5, 7, 9, 11]);
        part2_pro = group2(j, [1, 3, 5, 7, 9, 11]);
        part1_anti = group2(i, [2, 4, 6, 8, 10, 12]);
        part2_anti = group2(j, [2, 4, 6, 8, 10, 12]);        
        multivariate_behavioral_RDM.kmeans_pro_group2(j, i) = norm(part1_pro - part2_pro);
        multivariate_behavioral_RDM.kmeans_anti_group2(j, i) = norm(part1_anti - part2_anti);        
    end
end
clear i j part* 

multivariate_behavioral_RDM.kmeans_pro_group2 = [multivariate_behavioral_RDM.kmeans_pro_group2, zeros(56, 1)];
multivariate_behavioral_RDM.kmeans_anti_group2 = [multivariate_behavioral_RDM.kmeans_anti_group2, zeros(56, 1)];


%% Subset neural RDMs into group1 & group2

load('neural_RDMs.mat')

[~, idx_group1_insideValid] = intersect(validSubjs_behav_neu, group1_ID);
[~, idx_group2_insideValid] = intersect(validSubjs_behav_neu, group2_ID);

sEUD_neuBehav_ox.pro_kmeans_group1 = sEUD_neuBehav_ox.pro(idx_group1_insideValid, idx_group1_insideValid, :);
sEUD_neuBehav_ox.anti_kmeans_group1 = sEUD_neuBehav_ox.anti(idx_group1_insideValid, idx_group1_insideValid, :);
sEUD_neuBehav_ox.pro_kmeans_group2 = sEUD_neuBehav_ox.pro(idx_group2_insideValid, idx_group2_insideValid, :);
sEUD_neuBehav_ox.anti_kmeans_group2 = sEUD_neuBehav_ox.anti(idx_group2_insideValid, idx_group2_insideValid, :);


% Group 1, pro
behavioral_RDM = multivariate_behavioral_RDM.kmeans_pro_group1;
neural_RDM = sEUD_neuBehav_ox.pro_kmeans_group1;

for chan = 1:108  
    chan_RDM = tril(neural_RDM(:, :, chan), -1);
    chan_RDM = chan_RDM(chan_RDM ~= 0);
    behav_RDM = tril(behavioral_RDM, -1);
    behav_RDM = behav_RDM(behav_RDM ~= 0);
    [rho_pro_group1(chan), p_pro_group1(chan)] = corr(chan_RDM, behav_RDM, 'type', 'Spearman', 'rows', 'pairwise');
end
clear chan* behav_RDM

% Group 1, anti
behavioral_RDM = multivariate_behavioral_RDM.kmeans_anti_group1;
neural_RDM = sEUD_neuBehav_ox.anti_kmeans_group1;

for chan = 1:108  
    chan_RDM = tril(neural_RDM(:, :, chan), -1);
    chan_RDM = chan_RDM(chan_RDM ~= 0);
    behav_RDM = tril(behavioral_RDM, -1);
    behav_RDM = behav_RDM(behav_RDM ~= 0);
    [rho_anti_group1(chan), p_anti_group1(chan)] = corr(chan_RDM, behav_RDM, 'type', 'Spearman', 'rows', 'pairwise');
end
clear chan* behav_RDM

% Group 2, pro
behavioral_RDM = multivariate_behavioral_RDM.kmeans_pro_group2;
neural_RDM = sEUD_neuBehav_ox.pro_kmeans_group2;

for chan = 1:108  
    chan_RDM = tril(neural_RDM(:, :, chan), -1);
    chan_RDM = chan_RDM(chan_RDM ~= 0);
    mask = tril(true(size(behavioral_RDM)),-1);
    behav_RDM = behavioral_RDM(mask);
    [rho_pro_group2(chan), p_pro_group2(chan)] = corr(chan_RDM, behav_RDM, 'type', 'Spearman', 'rows', 'pairwise');
end
clear chan* behav_RDM mask

% Group 2, anti
behavioral_RDM = multivariate_behavioral_RDM.kmeans_anti_group2;
neural_RDM = sEUD_neuBehav_ox.anti_kmeans_group2;

for chan = 1:108  
    chan_RDM = tril(neural_RDM(:, :, chan), -1);
    chan_RDM = chan_RDM(chan_RDM ~= 0);
    mask = tril(true(size(behavioral_RDM)),-1);
    behav_RDM = behavioral_RDM(mask);
    [rho_anti_group2(chan), p_anti_group2(chan)] = corr(chan_RDM, behav_RDM, 'type', 'Spearman', 'rows', 'pairwise');
end
clear chan* behav_RDM mask behavioral_RDM neural_RDM

%% ROI analysis

% 
