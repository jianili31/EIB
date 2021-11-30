
vmpfc_allvids = raw_ox.neuBehav_allvids_ox(:, vmpfc, :);
rtpjipl_allvids = raw_ox.neuBehav_allvids_ox(:, r_tpjipl, :);
ltpjipl_allvids = raw_ox.neuBehav_allvids_ox(:, l_tpjipl, :);

%% VMPFC
% Remove timecourses that contain NaN in any one of the 3 VMPFC channels
% Remove those subjects' behavioral distances as well
behav_RDM = multivariate_behavioral_RDM.allvids;

i = 1;
while (i <= size(vmpfc_allvids, 3))
    if any(any(isnan((vmpfc_allvids(:, :, i)))))
        vmpfc_allvids(:, :, i) = [];
        behav_RDM(i, :) = [];
        behav_RDM(:, i) = [];
    else
        i = i + 1;
    end
end
Nvalidsubj = size(vmpfc_allvids, 3);
raw_ox.vmpfc_allvids = squeeze(mean(vmpfc_allvids, 2));
clear vmpfc_allvids

% Build neural RDM
sEUD_neuBehav_ox.allvids_vmpfc = zeros(Nvalidsubj);
for part1 = 1:(Nvalidsubj-1)
    for part2 = (part1+1):Nvalidsubj
        TC1 = raw_ox.vmpfc_allvids(:, part1);
        TC2 = raw_ox.vmpfc_allvids(:, part2);
        sEUD_neuBehav_ox.allvids_vmpfc(part2, part1) = norm(TC1 - TC2);
    end
end
clear part* TC* 

% Correlate behavioral & neural RDMs
[rho_vmpfc, p_vmpfc] = corr(sEUD_neuBehav_ox.allvids_vmpfc(sEUD_neuBehav_ox.allvids_vmpfc ~= 0),...
    behav_RDM(behav_RDM ~= 0), 'type', 'Spearman');


%% RTPJIPL
behav_RDM = multivariate_behavioral_RDM.allvids;

i = 1;
while (i <= size(rtpjipl_allvids, 3))
    if any(any(isnan((rtpjipl_allvids(:, :, i)))))
        rtpjipl_allvids(:, :, i) = [];
        behav_RDM(i, :) = [];
        behav_RDM(:, i) = [];
    else
        i = i + 1;
    end
end
Nvalidsubj = size(rtpjipl_allvids, 3);
raw_ox.rtpjipl_allvids = squeeze(mean(rtpjipl_allvids, 2));
clear rtpjipl_allvids

% Build neural RDM
sEUD_neuBehav_ox.allvids_rtpjipl = zeros(Nvalidsubj);
for part1 = 1:(Nvalidsubj-1)
    for part2 = (part1+1):Nvalidsubj
        TC1 = raw_ox.rtpjipl_allvids(:, part1);
        TC2 = raw_ox.rtpjipl_allvids(:, part2);
        sEUD_neuBehav_ox.allvids_rtpjipl(part2, part1) = norm(TC1 - TC2);
    end
end
clear part* TC* 

% Correlate behavioral & neural RDMs
[rho_rtpjipl, p_rtpjipl] = corr(sEUD_neuBehav_ox.allvids_rtpjipl(sEUD_neuBehav_ox.allvids_rtpjipl ~= 0),...
    behav_RDM(behav_RDM ~= 0), 'type', 'Spearman');


%% LTPJIPL
behav_RDM = multivariate_behavioral_RDM.allvids;

i = 1;
while (i <= size(ltpjipl_allvids, 3))
    if any(any(isnan((ltpjipl_allvids(:, :, i)))))
        ltpjipl_allvids(:, :, i) = [];
        behav_RDM(i, :) = [];
        behav_RDM(:, i) = [];        
    else
        i = i + 1;
    end
end
Nvalidsubj = size(ltpjipl_allvids, 3);
raw_ox.ltpjipl_allvids = squeeze(mean(ltpjipl_allvids, 2));
clear ltpjipl_allvids

% Build neural RDM
sEUD_neuBehav_ox.allvids_ltpjipl = zeros(Nvalidsubj);
for part1 = 1:(Nvalidsubj-1)
    for part2 = (part1+1):Nvalidsubj
        TC1 = raw_ox.ltpjipl_allvids(:, part1);
        TC2 = raw_ox.ltpjipl_allvids(:, part2);
        sEUD_neuBehav_ox.allvids_ltpjipl(part2, part1) = norm(TC1 - TC2);
    end
end
clear part* TC* 

% Correlate behavioral & neural RDMs
[rho_ltpjipl, p_ltpjipl] = corr(sEUD_neuBehav_ox.allvids_ltpjipl(sEUD_neuBehav_ox.allvids_ltpjipl ~= 0),...
    behav_RDM(behav_RDM ~= 0), 'type', 'Spearman');


%% Repeat procedures, without removing NaN subjects

vmpfc_allvids = squeeze(mean(raw_ox.neuBehav_allvids_ox(:, vmpfc, :), 2, 'omitnan'));
rtpjipl_allvids = squeeze(mean(raw_ox.neuBehav_allvids_ox(:, r_tpjipl, :), 2, 'omitnan'));
ltpjipl_allvids = squeeze(mean(raw_ox.neuBehav_allvids_ox(:, l_tpjipl, :), 2, 'omitnan'));

vmpfc_EUD = zeros(104);
for part1 = 1:103
    for part2 = (part1+1):104
        TC1 = vmpfc_allvids(:, part1);
        TC2 = vmpfc_allvids(:, part2);
        vmpfc_EUD(part2, part1) = norm(TC1 - TC2);
    end
end

rtpjipl_EUD = zeros(104);
for part1 = 1:103
    for part2 = (part1+1):104
        TC1 = rtpjipl_allvids(:, part1);
        TC2 = rtpjipl_allvids(:, part2);
        rtpjipl_EUD(part2, part1) = norm(TC1 - TC2);
    end
end

ltpjipl_EUD = zeros(104);
for part1 = 1:103
    for part2 = (part1+1):104
        TC1 = ltpjipl_allvids(:, part1);
        TC2 = ltpjipl_allvids(:, part2);
        ltpjipl_EUD(part2, part1) = norm(TC1 - TC2);
    end
end
clear part* TC*

behav_RDM = multivariate_behavioral_RDM.allvids;
[rho_vmpfc_withnan, p_vmpfc_withnan] = corr(vmpfc_EUD(vmpfc_EUD ~= 0),...
    behav_RDM(behav_RDM ~= 0), 'type', 'Spearman', 'rows', 'pairwise');
[rho_rtpjipl_withnan, p_rtpjipl_withnan] = corr(rtpjipl_EUD(rtpjipl_EUD ~= 0),...
    behav_RDM(behav_RDM ~= 0), 'type', 'Spearman', 'rows', 'pairwise');
[rho_ltpjipl_withnan, p_ltpjipl_withnan] = corr(ltpjipl_EUD(ltpjipl_EUD ~= 0),...
    behav_RDM(behav_RDM ~= 0), 'type', 'Spearman', 'rows', 'pairwise');

save("multivariate_results.mat", "rho_vmpfc", "rho_rtpjipl", "rho_ltpjipl", ...
    "p_vmpfc", "p_rtpjipl", "p_ltpjipl", "sEUD_neuBehav_ox", "-append")
