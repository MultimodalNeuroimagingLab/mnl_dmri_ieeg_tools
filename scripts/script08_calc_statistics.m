%   Jordan Bilderbeek July 19 2023; updated August 3
%
%   Script to calculate statistics (distance and angles) for one subject.
%   Change subnum to move through the subject labels. 
%   We save all the statistics in the el struct. 
%
%   The structure is organized as a 1x16 with fields name and trackstats.
%   Name is the electrode contact # and either R/L. If we index into the
%   el.trackstats, it is a 1xN structure array with name of the fibers,
%   fibers (points), distance, and angle. 
%
%   To pull out a the angle between a specific electrode and fiber, index
%   via el(contact#).trackstats(track#).angle.
%
%   NaN's are present in the el.trackstats.angle when there were less than
%   two points under X distance (set in the strm_angle function call) as we
%   cannot fit the PC axis and calculate the subsequent angle. 


%% Load all data and get tracks
clear all;
close all;

subnum=5;
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label]);
[Ltracks, Rtracks]=getDSItracks(dsipath);
[Ltracks, Rtracks]=gz_unzip(Ltracks, Rtracks);

%Load DWI file:
switch subnum
    case 2
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    case 5
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    case 4
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    otherwise
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_rec-none_run-01_space-T1w_desc-preproc_dwi.nii.gz']);
end

% DWI data
ni_dwi = niftiRead(dwi_file);
[fg_fromtrk]=create_trkstruct(ni_dwi, Rtracks);

% Electrode positions
electrode_tsv=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];
%% Custom ROI - load ROIs

%Hippocampus segmentations
hippocampus=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' );
hippocampalsegR=-32482;
hippocampalsegL=-32676;

%ANT segmentations for L ventral (AV), dorsal (AD), and medial (AM)
l_AV=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lAV.nii');
l_AD=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lAD.nii');
l_AM=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lAM.nii');

%ANT segmentations for R ventral (AV), dorsal (AD), and medial (AM)
r_AV=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAV.nii');
r_AD=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAD.nii');
r_AM=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAM.nii');

%% Compute distances and angle for right side

electrodes={'RA1', 'RA2', 'RA3', 'RA4', 'RH1', 'RH2', 'RH3', 'RH4' }; %select right side electrodes
for ii=1:length(electrodes)
    el(ii+8).name=electrodes{ii};
    fg_fromtrk=strm_distance(fg_fromtrk, elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :));
    el(ii+8).trackstats = strm_angle(fg_fromtrk,elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), 4);
    el(ii+8).hippocampus_r_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), hippocampus, hippocampalsegR);
    el(ii+8).AV_r_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), r_AV, 'Ventral ANT');
    el(ii+8).AD_r_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), r_AD, 'Dorsal ANT');
    el(ii+8).AM_r_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), r_AM, 'Medial ANT');
end

%% Compute distances and angle for left side

[fg_fromtrk]=create_trkstruct(ni_dwi, Ltracks); %recompute with left tracks
electrodes={'LA1', 'LA2', 'LA3', 'LA4', 'LH1', 'LH2', 'LH3', 'LH4' };
for ii=1:length(electrodes)
    el(ii).name=electrodes{ii};
    fg_fromtrk=strm_distance(fg_fromtrk, elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :));
    el(ii).trackstats = strm_angle(fg_fromtrk,elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), 4);
    el(ii).hippocampus_l_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), hippocampus, hippocampalsegL);
    el(ii).AV_l_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), l_AV, 'Ventral ANT');
    el(ii).AD_l_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), l_AD, 'Dorsal ANT');
    el(ii).AM_l_dist=roi_distance(elecmatrix(ismember(electrode_tsv.label,electrodes{ii}), :), l_AM, 'Medial ANT');
end

%% save statistics
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
save(dsipath, 'el');
