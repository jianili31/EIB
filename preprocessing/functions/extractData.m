function [d, sd_ind, samprate, wavelengths, s] = extractData(subjfolder)
    wl1file = dir(strcat(subjfolder,'/','*.wl1'));
    wl2file = dir(strcat(subjfolder,'/','*.wl2'));
    hdrfile = dir(strcat(subjfolder,'/','*.hdr'));
    wl1filename = wl1file(1).name;
    wl2filename = wl2file(1).name;
    hdrfilename = hdrfile(1).name;
    wl1=load(strcat(subjfolder,'/',wl1filename));
    wl2=load(strcat(subjfolder,'/',wl2filename));
    d=[wl1 wl2];

    fid = fopen(strcat(subjfolder,'/',hdrfilename));
    tmp = textscan(fid,'%s','delimiter','\n');%This just reads every line
    hdrString = tmp{1};
    fclose(fid);

    samprate = readSamplingRate(hdrString);
    sd_ind = getSDMask(hdrString);
    wavelengths = readWavelengths(hdrString);
    d = d(:,sd_ind);
    s = readEvents(hdrString, d);
end