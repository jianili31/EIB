clear all
load emotion_scores_normalized.mat
pairs = [{'Like_Pro1'} {'Like_Anti1'} {'Like_Pro2'} {'Like_Anti2'} ...
    {'Bother_Pro1'} {'Bother_Anti1'} {'Bother_Pro2'} {'Bother_Anti2'} ...
    {'Experience_Pro1'} {'Experience_Anti1'} {'Experience_Pro2'} {'Experience_Anti2'}];

% For each video, create a 3*120 matrix: column = 3D vector <Like, Bother,
% Experience>

emotion_vectors.pro1 = [dataemotionQsreordered(:, 1) dataemotionQsreordered(:, 1+4) dataemotionQsreordered(:, 1+8)]';
emotion_vectors.anti1 = [dataemotionQsreordered(:, 2) dataemotionQsreordered(:, 2+4) dataemotionQsreordered(:, 2+8)]';
emotion_vectors.pro2 = [dataemotionQsreordered(:, 3) dataemotionQsreordered(:, 3+4) dataemotionQsreordered(:, 3+8)]';
emotion_vectors.anti2 = [dataemotionQsreordered(:, 4) dataemotionQsreordered(:, 4+4) dataemotionQsreordered(:, 4+8)]';

% emotion_vectors.pro = (emotion_vectors.pro1 + emotion_vectors.pro2)/2;
% emotion_vectors.anti = (emotion_vectors.anti1 + emotion_vectors.anti2)/2;

load('all_workspace_usefulVariables.mat', 'not_exclude')
emotion_vectors.pro1_neuBehav = emotion_vectors.pro1(:, not_exclude);
emotion_vectors.anti1_neuBehav = emotion_vectors.anti1(:, not_exclude);
emotion_vectors.pro2_neuBehav = emotion_vectors.pro2(:, not_exclude);
emotion_vectors.anti2_neuBehav = emotion_vectors.anti2(:, not_exclude);

%% Compute Euclidean distances between pairs of vectors

multivariate_behavioral_RDM.pro1 = NaN(104);
multivariate_behavioral_RDM.anti1 = NaN(104);
multivariate_behavioral_RDM.pro2 = NaN(104);
multivariate_behavioral_RDM.anti2 = NaN(104);


for part1 = 1:103
    for part2 = (part1 + 1):104
        v1_pro1 = emotion_vectors.pro1_neuBehav(:, part1);
        v2_pro1 = emotion_vectors.pro1_neuBehav(:, part2);
        v1_anti1 = emotion_vectors.anti1_neuBehav(:, part1);
        v2_anti1 = emotion_vectors.anti1_neuBehav(:, part2);
        multivariate_behavioral_RDM.pro1(part2, part1) = norm(v1_pro1 - v2_pro1);
        multivariate_behavioral_RDM.anti1(part2, part1) = norm(v1_anti1 - v2_anti1);
        
        v1_pro2 = emotion_vectors.pro2_neuBehav(:, part1);
        v2_pro2 = emotion_vectors.pro2_neuBehav(:, part2);
        v1_anti2 = emotion_vectors.anti2_neuBehav(:, part1);
        v2_anti2 = emotion_vectors.anti2_neuBehav(:, part2);
        multivariate_behavioral_RDM.pro2(part2, part1) = norm(v1_pro2 - v2_pro2);
        multivariate_behavioral_RDM.anti2(part2, part1) = norm(v1_anti2 - v2_anti2);
    end   
end
clear v1* v2* part*

% Average EUD across videos
multivariate_behavioral_RDM.pro = (multivariate_behavioral_RDM.pro1 + multivariate_behavioral_RDM.pro2) / 2;
multivariate_behavioral_RDM.anti = (multivariate_behavioral_RDM.anti1 + multivariate_behavioral_RDM.anti2) / 2;

save("emotion_vectors.mat", "emotion_vectors", "multivariate_behavioral_RDM")
