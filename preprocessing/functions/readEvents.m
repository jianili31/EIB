function s = readEvents(hdrString, d)
    keyword = 'Events="#';
    tmp = strfind(hdrString,keyword);
    ind = find(~cellfun(@isempty,tmp)) + 1; %This gives cell of hdr_str with keyword
    tmp = strfind(hdrString(ind+1:end),'#');
    ind2 = find(~cellfun(@isempty,tmp)) - 1;
    ind2 = ind + ind2(1);
    events = cell2mat(cellfun(@str2num,hdrString(ind:ind2),'UniformOutput',0));
    if ~isempty(events)
        events = events(:,2:3);
        events = events(events(:,2)~=0,:);
        markertypes = unique(events(:,1));
        s = zeros(size(d,1),length(markertypes));
        for j=1:length(markertypes)
            s(events(:,2))=1;
        end
    else
        s = zeros(size(d,1),1);
    end
end