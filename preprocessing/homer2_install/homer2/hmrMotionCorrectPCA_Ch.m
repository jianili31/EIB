% [dN,svs,nSV] = hmrMotionCorrectPCA( SD, d, tInc, nSV )
%
% UI NAME:
% PCA_Motion_Correction
%
% This function uses PCA to filter only the segments of data identified as
% a motion artifact. The motion artifacts are indicated in the tInc vector
% by the value of 0.
%
%
% INPUTS
% SD:   Source Detector Structure. The active data channels are indicated in
%       SD.MeasListAct.
% d:    data matrix, timepoints x sd pairs
% tInc: a vector of length time points with 1's indicating data included
%       and 0's indicating motion artifact
% nSV: This is the number of principal components to remove from the data.
%      If this number is less than 1, then the filter removes the first n
%      components of the data that removes a fraction of the variance
%      up to nSV.
%
% OUTPUTS
% dN: This the the motion corrected data.
% svs: the singular values of the PCA
% nSV: number of singular values removed from the data.
 
 
function [dN,svs,nSV] = hmrMotionCorrectPCA_Ch( SD, d, tInc, tIncCh, nSV)
 
% percent variance you want to remove, or give an integer for number of
% components to remove
%nSV = .9;
 
 
% get output results from Homer2ui
mlAct = SD.MeasListAct; % prune bad channels
%tInc = procResult.tIncAuto;        % identify motion (vector of 1-no motion, and 0-motion)
 
%dod = procResult.dod;  % delta OD
 
 
lstNoInc = find(tInc==0);
lstAct = find(mlAct==1);
 
if isempty(lstNoInc)
    dN = d;
    svs = [];
    nSV = 0;
    return;
end
 
    
    
%
% Do PCA
%
y = d(lstNoInc,lstAct);
yc = y;
yo = y;
 
c = y.' * y;
[V,St,foo] = svd(c);
svs = diag(St) / sum(diag(St));
 
svsc = svs;
for idx = 2:size(svs,1)
    svsc(idx) = svsc(idx-1) + svs(idx);
end
if nSV<1 & nSV>0 % find number of SV to get variance up to nSV
    ev = diag(svsc<nSV);
    nSV = find(diag(ev)==0,1)-1;
end
 
ev = zeros(size(svs,1),1);
ev(1:nSV) = 1;
ev = diag(ev);
 
yc = yo - y*V*ev*V';

% splice the segments of data together
dN = d;

%% CORRECTION BY CHANNEL
for ii = 1:size(lstAct,1);
    
lstMs = find(diff(tIncCh(:,lstAct(ii)))==-1);
%lstMs(find(tInc(lstMs)==0))=lstMs(find(tInc(lstMs)==0))-1; % for tInc tIncCh consistency on the start of the motion MAY
lstMf = find(diff(tIncCh(:,lstAct(ii)))==1);
 
if isempty(lstMs)==0 && isempty(lstMf)==0
 
if isempty(lstMf) 
    lstMf = length(tIncCh(:,lstAct(ii)));
end
if isempty(lstMs)
    lstMs = 1;
end
if lstMs(1)>lstMf(1)
    lstMs = [1;lstMs];
end
if lstMs(end)>lstMf(end)
    lstMf(end+1,1) = length(lstAct(ii));
end
lstMb = lstMf-lstMs;
for kk=2:length(lstMb)
    lstMb(kk) = lstMb(kk-1) + lstMb(kk);
end
 
jj = lstAct(ii);
lst = (lstMs(1)):(lstMf(1)-1);
 
 
 
 
if  isempty(lst) == 0;
    if lstMs(1)>1
        dN(lst,jj) = yc(1:lstMb(1),ii) - yc(1,ii) + dN(lst(1),jj);
    else
        dN(lst,jj) = yc(1:lstMb(1),ii) - yc(lstMb(1),ii) + dN(lst(end),jj);
    end
 
    for kk=1:(length(lstMf)-1)
        lst = (lstMf(kk)-1):lstMs(kk+1);
        if  isempty(lst) == 0;
        dN(lst,jj) = d(lst,jj) - d(lst(1),jj) + dN(lst(1),jj);
        end
        
        lst = (lstMs(kk+1)):(lstMf(kk+1)-1);
        if  isempty(lst) == 0;
        dN(lst,jj) = yc((lstMb(kk)+1):lstMb(kk+1),ii) - yc(lstMb(kk)+1,ii) + dN(lst(1),jj);
        end
    end
    
    if lstMf(end)<length(d)
        lst = (lstMf(end)-1):length(d);
        if  isempty(lst) == 0;
            if lst(1)==0;
                lst(1)=1;
            end
        dN(lst,jj) = d(lst,jj) - d(lst(1),jj) + dN(lst(1),jj);    
        end
    end
end 
end
clear lstMb lstMs lstMf lst
end