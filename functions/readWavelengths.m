function wavelengths = readWavelengths(hdrString)
    keyword = 'Wavelengths=';
    tmp = strfind(hdrString,keyword);
    ind = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
    tmp = hdrString{ind};
    Wavelength1 = str2double(tmp(length(keyword)+2:length(keyword)+5));
    Wavelength2 = str2double(tmp(end-4:end-1));
    wavelengths = [Wavelength1 Wavelength2];
end