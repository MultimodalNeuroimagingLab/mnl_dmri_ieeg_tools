%   Jordan Bilderbeek July 19 2023
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


%% calc statistics - distance and angle (RIGHT SIDE - el 9:16)
% this assumes we have the right side fg_fromtrk struct and are using
% elecmatrix(9:16, :)
subnum=3;
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label]);
[Ltracks, Rtracks]=getDSItracks(dsipath);
[Ltracks, Rtracks]=gz_unzip(Ltracks, Rtracks);

%Load DWI file:
switch subnum
    case 2
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    case 4
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    otherwise
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_rec-none_run-01_space-T1w_desc-preproc_dwi.nii.gz']);
end

%DWI data
ni_dwi = niftiRead(dwi_file);
[fg_fromtrk]=create_trkstruct(ni_dwi, Rtracks);

%Electrode Positions
electrodepositions = fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']);
elecmatrix=readtable(electrodepositions, 'FileType', 'text', 'Delimiter', '\t');
elecmatrix=table2array(elecmatrix);

%Custom ROI
roifile=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz');
hippocampalsegR=-32482;

for ii=1:length(elecmatrix)/2
    el(ii+8).name=['R-Electrode ' num2str(ii+8)];
    fg_fromtrk=strm_distance(fg_fromtrk, elecmatrix(ii+8, :));
    el(ii+8).trackstats = strm_angle(fg_fromtrk,elecmatrix(ii+8, :), 4);
    el(ii+8).hippocampus_R_dist=roi_distance(elecmatrix(ii+8, :), roifile, hippocampalsegR);
end

%% calc statistics - distance and angle (LEFT SIDE - el 1:8)
disp('Now calculating left side')
[fg_fromtrk]=create_trkstruct(ni_dwi, Ltracks);

hippocampalsegL=-32676;

for ii=1:length(elecmatrix)/2
    el(ii).name=['L-Electrode ' num2str(ii)];
    fg_fromtrk=strm_distance(fg_fromtrk, elecmatrix(ii, :));
    el(ii).trackstats = strm_angle(fg_fromtrk,elecmatrix(ii, :), 4);
    el(ii).hippocampus_L_dist=roi_distance(elecmatrix(ii, :), roifile, hippocampalsegL);

end

%% save statistics
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
save(dsipath, 'el');
