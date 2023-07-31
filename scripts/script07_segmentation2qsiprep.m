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
sub_name = my_subject_labels{1}; 

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

leadDBST1=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'anat_t1.nii'));
acpc2qsiprepXform = dtiRawAlignToT1(leadDBST1, qsiprep_T1,[],[], false, 1); 

%load dorsal, medial, ventral ANT
R_AD=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'rh', 'AD.nii')); 
R_AD.qto_xyz = acpc2qsiprepXform;
R_AD.qto_ijk = inv(acpc2qsiprepXform);
R_AD.sto_xyz = acpc2qsiprepXform;
R_AD.sto_ijk = inv(acpc2qsiprepXform);
R_AD_save_name = regexprep(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'rh', 'AD.nii'), '.nii', '_preproc.nii');
niftiWrite(R_AD,R_AD_save_name)


R_AM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'rh', 'AM.nii')); 
R_AM.qto_xyz = acpc2qsiprepXform;
R_AM.qto_ijk = inv(acpc2qsiprepXform);
R_AM.sto_xyz = acpc2qsiprepXform;
R_AM.sto_ijk = inv(acpc2qsiprepXform);

R_AV=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'rh', 'AV.nii')); 
R_AV.qto_xyz = acpc2qsiprepXform;
R_AV.qto_ijk = inv(acpc2qsiprepXform);
R_AV.sto_xyz = acpc2qsiprepXform;
R_AV.sto_ijk = inv(acpc2qsiprepXform);

L_AD=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'lh', 'AD.nii')); 
L_AD.qto_xyz = acpc2qsiprepXform;
L_AD.qto_ijk = inv(acpc2qsiprepXform);
L_AD.sto_xyz = acpc2qsiprepXform;
L_AD.sto_ijk = inv(acpc2qsiprepXform);


L_AM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'lh', 'AM.nii')); 
L_AM.qto_xyz = acpc2qsiprepXform;
L_AM.qto_ijk = inv(acpc2qsiprepXform);
L_AM.sto_xyz = acpc2qsiprepXform;
L_AM.sto_ijk = inv(acpc2qsiprepXform);


L_AV=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'lh', 'AV.nii')); 
L_AV.qto_xyz = acpc2qsiprepXform;
L_AV.qto_ijk = inv(acpc2qsiprepXform);
L_AV.sto_xyz = acpc2qsiprepXform;
L_AV.sto_ijk = inv(acpc2qsiprepXform);

