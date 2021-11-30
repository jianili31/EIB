clear all

addpath '/Users/jianili/Desktop/OIB/BehavioralData'

load emotion_vectors.mat
load neural_RDMs.mat

%% Correlate each layer of neural RDM with behavioral RDM

behavioral_RDM_anti = multivariate_behavioral_RDM.anti(~isnan(multivariate_behavioral_RDM.anti));
behavioral_RDM_pro = multivariate_behavioral_RDM.pro(~isnan(multivariate_behavioral_RDM.pro));

for chan = 1:108
    neural_RDM_anti = tril(sEUD_neuBehav_ox.anti(:, :, chan), -1);
    neural_RDM_anti = neural_RDM_anti(neural_RDM_anti ~= 0);
    [rho_anti(chan), p_anti(chan)] = corr(neural_RDM_anti, behavioral_RDM_anti, 'type', 'Spearman', 'rows', 'pairwise');
    
    neural_RDM_pro = tril(sEUD_neuBehav_ox.pro(:, :, chan), -1);
    neural_RDM_pro = neural_RDM_pro(neural_RDM_pro ~= 0);
    [rho_pro(chan), p_pro(chan)] = corr(neural_RDM_pro, behavioral_RDM_pro, 'type', 'Spearman', 'rows', 'pairwise');
end
clear *_RDM_ chan neural_RDM* behavioral_RDM*

%% Concatenate neural TC's & behavioral scores across all videos

raw_ox.neuBehav_allvids_ox = [raw_ox.neuBehav_anti; raw_ox.neuBehav_pro];
emotion_vectors.allvids_neuBehav = [emotion_vectors.anti1_neuBehav; emotion_vectors.anti2_neuBehav;...
    emotion_vectors.pro1_neuBehav; emotion_vectors.pro2_neuBehav];

% Re-calculate behavioral EUD
% 1) Concatenate 3D emotion vectors across all videos
emotion_vectors.allvids_neuBehav = [emotion_vectors.anti1_neuBehav; emotion_vectors.anti2_neuBehav; emotion_vectors.pro1_neuBehav; emotion_vectors.pro2_neuBehav];

% 2) Calculate EUD between pairs of vectors

multivariate_behavioral_RDM.allvids = zeros(104);

for part1 = 1:103
    for part2 = (part1 + 1):104
        v1 = emotion_vectors.allvids_neuBehav(:, part1);
        v2 = emotion_vectors.allvids_neuBehav(:, part2);
        multivariate_behavioral_RDM.allvids(part2, part1) = norm(v1 - v2);
    end
end
clear v1 v2 part1 part2


% Correlate neural & behavioral RDM

[allvids, rho_allvids, p_allvids]...
    = correlate_neural_behav(raw_ox.neuBehav_allvids_ox, multivariate_behavioral_RDM.allvids);
sEUD_neuBehav_ox.allvids = allvids;
clear allvids

save("multivariate_results.mat", "sEUD_neuBehav_ox", "p*", "rho*", "multivariate_behavioral_RDM")
 
