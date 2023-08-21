%   Jordan Bilderbeek August 4 2023
%
%   this script was built to calculate the distance of a track between two
%   given electrode contacts. this will allow us to determine the
%   conduction speed of the tracks and evaluate if the latency calculation
%   is correct
%

%% initialize

clear all; close all;

subnum=3;
[sub_label,bids_path, electrodes, tracks, elpair] = limbic_subject_library(subnum);

for ii=1:length(tracks)
    sep=regexp(tracks(ii), '/', 'split');
    trk=sep{end}{end};
try
    if trk==elpair{3}
        ind=ii;
    end
catch
end
end

tracks=tracks(ind);
electrode_tsv=readtable(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
ni_dwi = niftiRead(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']));

%% Prep data for statistics

[fg_fromtrk]=create_trkstruct(ni_dwi, tracks); %create fg_fromtrk structure with all tracks
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];  

%% Calculate distances

% First for the distances: strm_distance calculates the minimum distance
% from contact to track, but also the index point. We can then use the ind
% to clip the track and calculate the euclidean distance from clip point 1
% to clip point 2. 
fg_fromtrk1=strm_distance(fg_fromtrk, elecmatrix(ismember(electrode_tsv.name,elpair{1}),:));
fg_fromtrk2=strm_distance(fg_fromtrk, elecmatrix(ismember(electrode_tsv.name,elpair{2}),:));

totaldistance=zeros(length(fg_fromtrk1.mindist), 1);
for ii=1:length(fg_fromtrk1.mindist)
    
    indices=[fg_fromtrk1.mindistind{ii}, fg_fromtrk2.mindistind{ii}]; %both of the clip points
    upperbound=max(indices); %sort
    lowerbound=min(indices);
    
    if lowerbound==upperbound %edge case, can trigger if contacts are very far away, or if streamline is cut short (not along the whole track)
        totaldistance(ii)=NaN; 
    else
        fibermat=fg_fromtrk.fibers{ii}(:, lowerbound:upperbound); %clip the streamline
        [total_distance] = trk_distance(fibermat(1,:), fibermat(2,:), fibermat(3,:), []); %calculate the streamline distance
        totaldistance(ii)=total_distance+fg_fromtrk1.mindist{ii}+fg_fromtrk2.mindist{ii}; %add the distance from probe to streamline point to streamline distance for total distance
    end
end

totaldiststruct=struct(); %save values in a structure
totaldiststruct.totaldistance=totaldistance;
totaldiststruct.totaldistancemean=mean(rmmissing(totaldistance));
totaldiststruct.totaldistancemedian=median(rmmissing(totaldistance));
totaldiststruct.pairs=[elpair{1} ' ' elpair{2}]; %note which electrode pairs and which tracks we are using
totaldiststruct.track=elpair{3};

savepath=fullfile(bids_path, 'derivatives','stats',['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_distpairs.mat']);
save(savepath, 'totaldiststruct');
