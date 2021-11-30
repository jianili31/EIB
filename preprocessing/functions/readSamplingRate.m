function samprate = readSamplingRate(hdrString)
    keyword = 'SamplingRate=';
    tmp = strfind(hdrString,keyword);
    ind = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
    tmp = hdrString{ind};
    samprate = str2num(tmp(length(keyword)+1:end));
end
