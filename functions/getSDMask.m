function sd_ind = getSDMask(hdrString)
    keyword = 'S-D-Mask="#';
    tmp = strfind(hdrString,keyword);
    ind = find(~cellfun(@isempty,tmp)) + 1; %This gives cell of hdr_str with keyword
    tmp = strfind(hdrString(ind+1:end),'#');
    ind2 = find(~cellfun(@isempty,tmp)) - 1;
    ind2 = ind + ind2(1);
    sd_ind = cell2mat(cellfun(@str2num,hdrString(ind:ind2),'UniformOutput',0));
    sd_ind = sd_ind';
    sd_ind = find([sd_ind(:);sd_ind(:)]);
end