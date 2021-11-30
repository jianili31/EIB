%%%%% new changes:
%incorporate durations
%incorporate breaks if there are no events
%save video based on order

%path must be in brain_data folder (where your raw data folders are)
%currently written to handle dyads
%required inpaint_nans, homer2 scripts, and huppertt (nirs-toolbox) scripts

%source code written by Shannon Burns: https://github.com/smburns47/preprocessingfNIRS
%modified by Jiani Li for EIB

%%%%%%%%%%%%%%%%%%%%%% USER INPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
study_dir='/Users/jianili/Desktop/OIB/preprocessingfNIRS-Macrina2/';
raw_dir=[study_dir,'fNIRS_data_videos'];
dataprefix='OIB';
probeInfoFile=0;
samprate=1.9531;

base_outpath=[study_dir, 'preprocessed_cut'];
if ~exist(base_outpath)
    mkdir(base_outpath)
end

orders=readtable([study_dir,'OIB_orders_triggers.xlsx']); % read in the orders
vid1_durs=[99 99 99 99 99 99 99 99]; %fill these in with the values based on the duration for the first video shown for each order
vid2_durs=[99 99 99 99 99 99 99 99];
vid3_durs=[99 99 99 99 99 99 99 99];
vid4_durs=[99 99 99 99 99 99 99 99];



%inputs: raw_dir: folder path with all single-subject or dyad-level raw data
%                 files (path must be relative to current matlab path).
%       dataprefix: string. Prefix of every folder name that should be considered a
%       data folder. E.g., MIN for MIN_101, MIN_102, etc. 
%       probeInfoFile: 0 or 1. If 0, will look for it in the first data folder.
%                 If 1, will ask you to provide a probeInfoFile before
%                 running.  
%       dyads: 0 or 1. 1 if hyperscanning, 0 if single subject.
%       dosubs: if all, leave at []. if you want to do a specific subset,
%       specify based on folder order, where 1 refers to first folder in data, etc.
%               -- e.g. [1:5, 9:15]
%
%outputs: preprocessed and .nirs files in same directory level as raw_dir

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DEBUGGING TIPS:
%Note that this function is, well, funcitonal, but not 100% optimized for
%everything that could go wrong. A couple problems I have noticed so far,
%and how to fix them if it comes up for you:
%   - If you get an "Index exceeds matrix dimensions" error in
%   hmrMotionArtifact for a subject that's not the first file: 
%       Check the SD Mask structure in the .hdr of that subject to see if 
%       it matches the SD Mask structure of subject 1. If the wrong montage
%       was selected in recording, will cause this error. Simply copy-paste
%       the correct SD Mask and ChannelDistance list into the .hdr file.
%   - Delete all false start files from the data directory, or will cause
%   script to error out. 

addpath(genpath([study_dir,'functions']));
%findhomer=dir([study_dir,'/homer2_install']);
addpath(genpath([study_dir,'homer2_install/homer2']));


currdir=dir(strcat(raw_dir,'/',dataprefix,'*'));
%if ~isempty(dosubs)
 %   currdir=currdir(dosubs);
%end
       
fprintf('\n\t Preprocessing ...\n')
reverseStr = '';
for i=1:length(currdir)
        subj=currdir(i).name;
        subjdir=dir(strcat(raw_dir,'/',subj,'/',dataprefix,'*'));
        %subjdir=dir(strcat(raw_dir,'/',subj);
        
        %find the subject's order
        row=find(strcmp(orders.sub,{subj}));
        order=orders.order(row);
        if order==1
            vid1='pro1';
            vid2='anti1';
            vid3='pro2';
            vid4='anti2';

        elseif order==2
            vid1='pro2';
            vid2='anti2';
            vid3='pro1';
            vid4='anti1';

        elseif order==3
            vid1='pro1';
            vid2='anti2';
            vid3='pro2';
            vid4='anti1';

        elseif order==4
            vid1='pro2';
            vid2='anti1';
            vid3='pro1';
            vid4='anti2';

        elseif order==5
            vid1='anti1';
            vid2='pro1';
            vid3='anti2';
            vid4='pro2';

        elseif order==6
            vid1='anti2';
            vid2='pro2';
            vid3='anti1';
            vid4='pro1';

        elseif order==7
            vid1='anti1';
            vid2='pro2';
            vid3='anti2';
            vid4='pro1';

        elseif order==8
            vid1='anti2';
            vid2='pro1';
            vid3='anti1';
            vid4='pro2';

        end
        
        
        msg = sprintf('\n\t subject number %d/%d ...',i,length(currdir));
        fprintf([reverseStr,msg]);
        reverseStr = repmat(sprintf('\b'),1,length(msg));
        for j=1:length(subjdir)
            event_ind=[];
            no_events=99;
            scanname = subjdir(j).name;
            subjfolder = strcat(raw_dir,'/',subj,'/',scanname);
            sprintf('\n\t doing scan %s',scanname)
            probefile = dir(strcat(subjfolder,'/','*_probeInfo.mat'));
            probefilename = probefile(1).name;
            load(strcat(subjfolder,'/',probefilename));

%             if ~probecheck
%                 error('ERROR: Cannot find probeInfo file in first subject folder');
%             end
            
            outpath = strcat(base_outpath,'/',subj,'/',scanname);
            if ~exist(outpath,'dir')
                %1) extract data values
                clear d sd_ind samprate wavelength s cutd;
                [d, sd_ind, samprate, wavelengths, s] = extractData(subjfolder);
                
                %This next part cuts the timecourses to match the onsets and
                %offsets recorded. It will find the onset and offset of the
                %video, and then cut down the timecourse to be between the
                %start of the video and then 10s after the video.
                
                extra_seconds=10;
                inds=find(s==1);
                for i=1:(length(inds)-1)
                    eventdiff=inds(i+1)-inds(i);
                    if eventdiff>200 %finds triggers for which there is at least 200. might change to be about video length?
                        start_t=inds(i);
                        end_t=inds(i+1);
                    end
                end
                
                cutd=d((start_t:end_t+extra_seconds),:); %only the timepoints that were from the video + 10s are shown
                d=cutd; %add in parts about if there are no events?
                
                
    
                %2) identify and remove bad channels
                %bad channel defined as any where detector saturation occurs for >2sec, 
                %or where power spectrum variation is too high. 
                %Feel free to change these parameters if you have a good reason to do so
                %
                %reasoning for default choices:
                %- if saturation occurs, data will be 'NaN'. But if this only lasts a
                %short amount of time (e.g. <8 points=<2 seconds at 4Hz), we can fill in what 
                %those data points would have likely been with reasonable confidence.
                %
                %- power spectrum of the signal shows how many sine waves at each freq.
                %make up the raw signal. Good signal should have a large peak at lower
                %frequencies. Pure noise will have random numbers of all freqencies. 
                %We will use a modified version of the quartile coefficient of
                %dispersion
                %(https://en.wikipedia.org/wiki/Quartile_coefficient_of_dispersion)
                %to automatically decide which channels have good or bad
                %signal. Essentially, it sums the frequency amplitudes in the
                %first and third quartiles of the frequency range, and then
                %compares them via (Q1-Q3)/(Q1+Q3). Larger QCoD is cleaner
                %signal. Default threshold is set to 0.1. Change this to <0.1 
                %to allow for greater noise in the signal, or change to >0.1 
                %for more stringency. 
    
                satlength = 2; %in seconds
                QCoDthresh = 0.1;
                [channelmask] = removeBadChannels(d, samprate, satlength, QCoDthresh);
    
                %3) convert to .nirs format
                [SD, aux, t] = getRemainingNirsVars(d, sd_ind, samprate, wavelengths, probeInfo, channelmask);
            
                %4) motion filter, convert to hemodynamic changes
                d=d;
                SD=SD;
                
                 %see hmrMotionArtifact in Homer2 documentation for parameter description
    numchannels = size(d,2)/2;
    % 1st change:
    % Originally: nothing here
    d(:,SD.MeasListAct==0)=NaN;
    
    % 2nd change:
    %tInc = hmrMotionArtifact(d, samprate, SD, ones(length(d)), 0.5, 2, 10, 5);
    tInc = hmrMotionArtifactByChannel(d, samprate, SD, ones(length(d)), 0.5, 2, 10, 5); %gives us a list of all timepoints with 1 for data looked good across channels and 0 if there seemed to be a major motion artifact across all channels
    %see hmrMotionCorrectPCA in Homer2 documentation for parameter description
    
    % filter the good channels that are left
    
    mlAct = SD.MeasListAct; %what are the good channels?
    
    
%tInc = procResult.tIncAuto;        % identify motion (vector of 1-no motion, and 0-motion)

%dod = procResult.dod;  % delta OD
    nSV = .9;

    lstNoInc = find(tInc==0); %find wherever there was a motion artifact across channels
    lstAct = find(mlAct==1); %index the good channels

    if isempty(lstNoInc)
        dN = d;
        svs = [];
        nSV = 0;
        %return;
    else

    %
    % Do PCA
    %
    y = d(lstNoInc,lstAct); % find where the "good" channels have a bit of bad motion
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


    %
    % splice the segments of data together
    %
    lstMs = find(diff(tInc)==-1);%find starts 
    lstMf = find(diff(tInc)==1);% and ends of bad sections
    if isempty(lstMf) 
        lstMf = length(tInc);
    end
    if isempty(lstMs)
        lstMs = 1;
    end
    if lstMs(1)>lstMf(1)
        lstMs = [1;lstMs];
    end
    if lstMs(end)>lstMf(end)
        lstMf(end+1,1) = length(tInc);
    end
    lstMb = lstMf-lstMs;
    for ii=2:length(lstMb)
        lstMb(ii) = lstMb(ii-1) + lstMb(ii);
    end

    dN = d;
    
    for ii=1:length(lstAct)

        jj = lstAct(ii);

        lst = (lstMs(1)):(lstMf(1)-1);
        if lstMs(1)>1
            dN(lst,jj) = yc(1:lstMb(1),ii) - yc(1,ii) + dN(lst(1),jj);
        else
            dN(lst,jj) = yc(1:lstMb(1),ii) - yc(lstMb(1),ii) + dN(lst(end),jj);
        end

        for kk=1:(length(lstMf)-1)
            lst = (lstMf(kk)-1):lstMs(kk+1);
            dN(lst,jj) = d(lst,jj) - d(lst(1),jj) + dN(lst(1),jj);

            lst = (lstMs(kk+1)):(lstMf(kk+1)-1);
            dN(lst,jj) = yc((lstMb(kk)+1):lstMb(kk+1),ii) - yc(lstMb(kk)+1,ii) + dN(lst(1),jj);
        end

        if lstMf(end)<length(d)
            lst = (lstMf(end)-1):length(d);
            dN(lst,jj) = d(lst,jj) - d(lst(1),jj) + dN(lst(1),jj);        
        end

    end
    end


    
    
    %3rd change:     
    %dfiltered=dN;
    dfiltered = BaselineVolatilityCorrection(d, samprate, SD, tInc);
    results = dN == dfiltered;
    results1 = find(~results);
    [dconverted, ~] = hmrIntensity2Conc(dfiltered, SD, samprate, 0.008, 0.2, [6, 6]);
    dnormed = zscore(dconverted);
    oxy = zeros(size(dconverted,1), numchannels);
    deoxy = zeros(size(dconverted,1), numchannels);
    totaloxy = zeros(size(dconverted,1), numchannels);
    z_oxy = zeros(size(dnormed,1), numchannels);
    z_deoxy = zeros(size(dnormed,1), numchannels);
    z_totaloxy = zeros(size(dnormed,1), numchannels);
    new_d = zeros(size(dconverted,1), numchannels*2);
    for c = 1:numchannels
        oxy(:,c) = dconverted(:,1,c);
        deoxy(:,c) = dconverted(:,2,c);
        totaloxy(:,c) = dconverted(:,3,c);
        z_oxy(:,c) = dnormed(:,1,c);
        z_deoxy(:,c) = dnormed(:,2,c);
        z_totaloxy(:,c) = dnormed(:,3,c);
        new_d(:,(c*2)-1) = oxy(:,c);
        new_d(:,c*2) = deoxy(:,c);
    end
                
                
                if no_events==1
                    outpath=strcat(outpath,'_NO_EVENTS');
                end
                mkdir(outpath) 
                save(strcat(outpath,'/',scanname,'_preprocessed.mat'),'oxy', 'deoxy', 'totaloxy','z_oxy', 'z_deoxy', 'z_totaloxy');
                save(strcat(outpath,'/',scanname,'.nirs'),'aux','d','s','SD','t');
                %resave by actual video
                if contains(scanname, 'video1')
                    resaveoutpath=strcat(base_outpath,'/',subj,'/',subj,'_',vid1);
                    mkdir(resaveoutpath);
                    save(strcat(resaveoutpath,'/',subj,'_',vid1,'_preprocessed.mat'),'oxy', 'deoxy', 'totaloxy','z_oxy', 'z_deoxy', 'z_totaloxy');
                    save(strcat(resaveoutpath,'/',subj,'_',vid1,'.nirs'),'aux','d','s','SD','t');
                elseif contains(scanname, 'video2')
                    resaveoutpath=strcat(base_outpath,'/',subj,'/',subj,'_',vid2);
                    mkdir(resaveoutpath);
                    save(strcat(resaveoutpath,'/',subj,'_',vid1,'_preprocessed.mat'),'oxy', 'deoxy', 'totaloxy','z_oxy', 'z_deoxy', 'z_totaloxy');
                    save(strcat(resaveoutpath,'/',subj,'_',vid2,'.nirs'),'aux','d','s','SD','t');
                elseif contains(scanname, 'video3')
                    resaveoutpath=strcat(base_outpath,'/',subj,'/',subj,'_',vid3);
                    mkdir(resaveoutpath);
                    save(strcat(resaveoutpath,'/',subj,'_',vid1,'_preprocessed.mat'),'oxy', 'deoxy', 'totaloxy','z_oxy', 'z_deoxy', 'z_totaloxy');
                    save(strcat(resaveoutpath,'/',subj,'_',vid3,'.nirs'),'aux','d','s','SD','t');
                elseif contains(scanname, 'video4')
                    resaveoutpath=strcat(base_outpath,'/',subj,'/',subj,'_',vid4);
                    mkdir(resaveoutpath);
                    save(strcat(resaveoutpath,'/',subj,'_',vid1,'_preprocessed.mat'),'oxy', 'deoxy', 'totaloxy','z_oxy', 'z_deoxy', 'z_totaloxy');
                    save(strcat(resaveoutpath,'/',subj,'_',vid4,'.nirs'),'aux','d','s','SD','t');
                end
            end
        end
end

dyads = 0;
multiscan = 1;
qualityAssessment(dataprefix,dyads,multiscan,size(d,2),samprate,0.1,strcat(raw_dir,filesep,'PreProcessedFiles'));

% Quality assessment?
%if anytofilter
    %qualityAssessment(dataprefix,dyads,multiscan,size(d,2),samprate,0.1,strcat(rawdir,filesep,'PreProcessedFiles'));
