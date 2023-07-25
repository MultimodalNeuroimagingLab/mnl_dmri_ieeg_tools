%   Jordan Bilderbeek July 18 2023
%
%   Script to take segmentations into qsi prep. We first perform a NN mri
%   convert in order to take the freesurfer space into ACPC T1. Once we are
%   in ACPC T1 space we can go to qsi space via dtiRawAlignToT1 - and take
%   the transformation matrix and apply to segmentation mask. 
%
%   Output file will live in freesurfer subject folder as
%   hippocampus_amygdala_lr_preproc.nii.gz file. 

%% run mri convert script

[my_subject_labels,bids_path] = dmri_subject_list();
sub_name = my_subject_labels{4}; 

resample_type= 'Nearest';
alignTo=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_name], ['sub-' sub_name '_ses-mri01_T1w_acpc.nii']);
segmentFile=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_name], sub_name, 'mri', 'aparc.a2009s+aseg.mgz');
outfile=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_name], sub_name, 'mri', 'hippocampus_amygdala_lr.nii.gz');

str = sprintf('! FREESURFER_HOME=/Applications/freesurfer/7.4.1 && source /Applications/freesurfer/7.4.1/SetUpFreeSurfer.sh && mri_convert  --out_orientation RAS --reslice_like %s -rt %s %s %s', alignTo, resample_type, segmentFile, outfile);
eval(str)
%% segmentation2qsiprep

acpcT1 = niftiRead(fullfile(bids_path,'BIDS_subjectsRaw','derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii']));

% qsiprep_T1
qsiprep_dir = fullfile(bids_path,'BIDS_subjectsRaw','derivatives','qsiprep',['sub-' sub_name]);
qsiprep_T1 = niftiRead(fullfile(qsiprep_dir,'anat',['sub-' sub_name '_desc-preproc_T1w.nii.gz']));
acpc2qsiprepXform = dtiRawAlignToT1(acpcT1,qsiprep_T1,[],[], false, 1); 

%% Hippocampus

Hip = niftiRead(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_name], sub_name, 'mri', 'hippocampus_amygdala_lr.nii.gz'));

Hip.qto_xyz = acpc2qsiprepXform;
Hip.qto_ijk = inv(acpc2qsiprepXform);
Hip.sto_xyz = acpc2qsiprepXform;
Hip.sto_ijk = inv(acpc2qsiprepXform);

Lh_save_name = regexprep(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_name], sub_name, 'mri', 'hippocampus_amygdala_lr.nii.gz'), '.nii.gz', '_preproc.nii.gz');
niftiWrite(Hip,Lh_save_name)

%% With ANT - have to find the xform - unknown T1 segmentation
% 
% % ANT T1
% %ANTT1 = niftiRead(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii']));
% 
% % ANT mask
% %ANT = niftiRead(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii']));
% 
% % qsiprep_T1
% qsiprep_dir = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name]);
% qsiprep_T1 = niftiRead(fullfile(qsiprep_dir,'anat',['sub-' sub_name '_desc-preproc_T1w.nii.gz']));
% 
% acpc2qsiprepXform = dtiRawAlignToT1(ANTT1,qsiprep_T1,[], ANT, false, 1); 
% 
% % Load L-ANT
% %Lant=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'Left-Hippocampus.nii.gz'));
% % Correct the xform matrix
% Lant.qto_xyz = acpc2qsiprepXform;
% Lant.qto_ijk = inv(acpc2qsiprepXform);
% Lant.sto_xyz = acpc2qsiprepXform;
% Lant.sto_ijk = inv(acpc2qsiprepXform);
% 
% % Load R-ANT
% %Rant=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'Left-Hippocampus.nii.gz'));
% % Corrext the xform matrix
% Rant.qto_xyz = acpc2qsiprepXform;
% Rant.qto_ijk = inv(acpc2qsiprepXform);
% Rant.sto_xyz = acpc2qsiprepXform;
% Rant.sto_ijk = inv(acpc2qsiprepXform);