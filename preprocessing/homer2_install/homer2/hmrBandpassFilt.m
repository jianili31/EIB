% y2 = hmrBandpassFilt( y, fs, hpf, lpf )
%
% UI NAME:
% Bandpass_Filter
%
% y2 = hmrBandpassFilt( y, fs, hpf, lpf )
% Perform a bandpass filter
%
% INPUT:
% y - data to filter #time points x #channels of data
% fs - sample frequency (Hz). If length(fs)>1 then this is assumed to be a time
%      vector from which fs is estimated
% hpf - high pass filter frequency (Hz)
%       Typical value is 0 to 0.02.
% lpf - low pass filter frequency (Hz)
%       Typical value is 0.5 to 3.
%
% OUTPUT:
% y2 - filtered data

function [y2,ylpf] = hmrBandpassFilt( y, fs, hpf, lpf )



% convert t to fs
% assume fs is a time vector if length>1
if length(fs)>1
    fs = 1/(fs(2)-fs(1));
end

badchannels = any(isnan(y));
yreduced = y(:,~badchannels); %new versions of Matlab's built in filtfilt 
                                %(2018+) can't handle NaN columns, so 
                                %reducing matrix here and expanding back 
                                %out after bandpass filtering

% low pass filter
FilterType = 1;
FilterOrder = 3;
%[fa,fb]=butter(FilterOrder,lpf*2/fs);
if FilterType==1 | FilterType==5
    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,lpf,'low');
elseif FilterType==4
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,lpf,'low',Filter_Rp,Filter_Rs);
else
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,lpf,'low',Filter_Rp);
end

yreducedlpf=filtfilt(fb,fa,yreduced);


% high pass filter
FilterType = 1;
FilterOrder = 5;
if FilterType==1 | FilterType==5
    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,hpf,'high');
elseif FilterType==4
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,hpf,'high',Filter_Rp,Filter_Rs);
else
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,hpf,'high',Filter_Rp);
end

if FilterType~=5
    y2reduced=filtfilt(fb,fa,yreducedlpf); 
else
    y2reduced = yreducedlpf;
end

ylpf = y;
y2 = y;
ylpf(:,~badchannels) = yreducedlpf;
y2(:,~badchannels) = y2reduced;

end
