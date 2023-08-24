%   Jordan Bilderbeek July 26 2023
%
%   Script to calculate statistics (distance) for one subject.
%   Change subnum to move through the subject labels. 
%   We save all the statistics in the limbic_dist_stats struct. 
%
%   The structure is organized as a 1xN with fields name and trackstats.
%   Name is the electrode contact and either R/L. If we index into the
%   el.trackstats, it is a 1xN structure array with name of the fibers,
%   fibers (points) distance, and mindistance.  
%

%% Find subject data
subnum=6;

% limbic_subject_library generates:
% a) electrodes - cell array of alphanumeric electrode positions that map
% to sub-[sub_label]_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv
% b) sub_label - sub label (ex: AAAA01234)
% c) bids_path - path to top of bids structure
% d) tracks - cell array of fullfile paths to unzipped .trk files
[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);

%% Load relevant files

electrode_tsv=readtable(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');

switch sub_label
    case '06'
        ni_dwi = niftiRead(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-axdti_space-T1w_desc-preproc_dwi.nii.gz']));
    otherwise
        ni_dwi = niftiRead(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']));
end
%% Prep data for statistics

[fg_fromtrk]=create_trkstruct(ni_dwi, tracks); %create fg_fromtrk structure with all tracks
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];  


hippocampus=fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'rhippocampus_amygdala_lr_preproc.nii' );
tag=electrodes{1}(1);
if tag=='R'
    hippocampalseg=53; %seg for R   
    HBT=fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'rrhippocampus_subfield_preproc.nii' );
    
else
    hippocampalseg=17; %seg for L   
    HBT=fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'rlhippocampus_subfield_preproc.nii' );

end

%% Calculate statistics
limbic_dist_stats=struct();
for ii=1:length(electrodes)
    limbic_dist_stats(ii).name=['Electrode Contact: ' electrodes{ii}]; %we assume that electrodes and xyz have same length which should always be the case
    fg_fromtrk=strm_distance(fg_fromtrk, elecmatrix(ismember(electrode_tsv.name,electrodes{ii}),:));
    limbic_dist_stats(ii).trackstats = strm_angle(fg_fromtrk,elecmatrix(ismember(electrode_tsv.name,electrodes{ii}),:), 4); %angle within 4mm
    
    limbic_dist_stats(ii).hippocampus_dist=roi_distance(elecmatrix(ismember(electrode_tsv.name,electrodes{ii}), :), hippocampus, hippocampalseg);    
    limbic_dist_stats(ii).hippocampus_body_dist=roi_distance(elecmatrix(ismember(electrode_tsv.name,electrodes{ii}), :), HBT, 231);    
    limbic_dist_stats(ii).hippocampus_tail_dist=roi_distance(elecmatrix(ismember(electrode_tsv.name,electrodes{ii}), :), HBT, 226);    
    limbic_dist_stats(ii).hippocampus_head_dist=roi_distance(elecmatrix(ismember(electrode_tsv.name,electrodes{ii}), :), HBT, 232);
end

savepath=fullfile(bids_path, 'derivatives','stats',['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_dist_angle_stats.mat']);
save(savepath, 'limbic_dist_stats');

