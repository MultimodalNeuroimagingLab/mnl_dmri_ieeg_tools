%   Jordan Bilderbeek July 18 2023
%
%   Script to take segmentations into qsi prep. We first perform a NN mri
%   convert in order to take the freesurfer space into ACPC T1. Once we are
%   in ACPC T1 space we can go to qsi space via dtiRawAlignToT1 - and take
%   the transformation matrix and apply to segmentation mask. 
%
%   Output file will live in freesurfer subject folder as
%   hippocampus_amygdala_lr_preproc.nii.gz file. 

%% load subject
subnum=6;
[sub_name,bids_path, ~, ~] = limbic_subject_library(subnum);

segmentFile=fullfile(bids_path, 'derivatives', 'freesurfer', ['sub-' sub_name], 'mri', 'aparc.a2009s+aseg.mgz');
outfile=fullfile(bids_path, 'derivatives', 'freesurfer', ['sub-' sub_name], 'mri', 'hippocampus_amygdala_lr.nii.gz');
str=['! FREESURFER_HOME=/Applications/freesurfer/7.4.1 && source /Applications/freesurfer/7.4.1/SetUpFreeSurfer.sh && mri_convert  --out_orientation RAS -rt Nearest ' segmentFile ' ' outfile];
eval(str)

%% SPM reslice
outfile=regexprep(outfile, '.gz', ''); %remove the .gz extension so that we can reslice
if ~exist(outfile, 'file')
    gunzip(strcat(outfile, '.gz'));
end

reslicecell=[{fullfile(bids_path,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii'])}; {outfile}];
spm_reslice(reslicecell);

outfile=regexprep(outfile, 'hippocampus', 'rhippocampus');

%% segmentation2qsiprep hippocampus
acpcT1 = niftiRead(fullfile(bids_path,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii']));

% qsiprep_T1
qsiprep_dir = fullfile(bids_path, 'derivatives','qsiprep',['sub-' sub_name]);
qsiprep_T1 = niftiRead(fullfile(qsiprep_dir,'anat',['sub-' sub_name '_desc-preproc_T1w.nii.gz']));
acpc2qsiprepXform = dtiRawAlignToT1(acpcT1,qsiprep_T1,[],[], false, 1); 

Hip = niftiRead(outfile);

Hip.qto_xyz = acpc2qsiprepXform;
Hip.qto_ijk = inv(acpc2qsiprepXform);
Hip.sto_xyz = acpc2qsiprepXform;
Hip.sto_ijk = inv(acpc2qsiprepXform);

Hip_save_name = regexprep(outfile, '.nii', '_preproc.nii');
niftiWrite(Hip,Hip_save_name)

%% Hippocampal subfields - left side

segmentFile=fullfile(bids_path, 'derivatives', 'freesurfer', ['sub-' sub_name], 'mri', 'lh.hippoAmygLabels-T1.v22.mgz');
outfile=fullfile(bids_path, 'derivatives', 'freesurfer', ['sub-' sub_name], 'mri', 'lhippocampus_subfield.nii.gz');
str=['! FREESURFER_HOME=/Applications/freesurfer/7.4.1 && source /Applications/freesurfer/7.4.1/SetUpFreeSurfer.sh && mri_convert  --out_orientation RAS -rt Nearest ' segmentFile ' ' outfile];
eval(str)

outfile=regexprep(outfile, '.gz', ''); %remove the .gz extension so that we can reslice
if ~exist(outfile, 'file')
    gunzip(strcat(outfile, '.gz'));
end
reslicecell=[{fullfile(bids_path,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii'])}; {outfile}];
spm_reslice(reslicecell);
outfile=regexprep(outfile, 'lhippocampus','rlhippocampus');

Hip = niftiRead(outfile);
Hip.qto_xyz = acpc2qsiprepXform;
Hip.qto_ijk = inv(acpc2qsiprepXform);
Hip.sto_xyz = acpc2qsiprepXform;
Hip.sto_ijk = inv(acpc2qsiprepXform);

lh_save_name = regexprep(outfile, '.nii', '_preproc.nii');
niftiWrite(Hip,lh_save_name)


%% Hippocampal subfields - right side
segmentFile=fullfile(bids_path, 'derivatives', 'freesurfer', ['sub-' sub_name], 'mri', 'rh.hippoAmygLabels-T1.v22.mgz');
outfile=fullfile(bids_path, 'derivatives', 'freesurfer', ['sub-' sub_name], 'mri', 'rhippocampus_subfield.nii.gz');
str=['! FREESURFER_HOME=/Applications/freesurfer/7.4.1 && source /Applications/freesurfer/7.4.1/SetUpFreeSurfer.sh && mri_convert  --out_orientation RAS -rt Nearest ' segmentFile ' ' outfile];
eval(str)

outfile=regexprep(outfile, '.gz', ''); %remove the .gz extension so that we can reslice
if ~exist(outfile, 'file')
    gunzip(strcat(outfile, '.gz'));
end
reslicecell=[{fullfile(bids_path,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii'])}; {outfile}];
spm_reslice(reslicecell);
outfile=regexprep(outfile, 'rhippocampus', 'rrhippocampus');

Hip = niftiRead(outfile);
Hip.qto_xyz = acpc2qsiprepXform;
Hip.qto_ijk = inv(acpc2qsiprepXform);
Hip.sto_xyz = acpc2qsiprepXform;
Hip.sto_ijk = inv(acpc2qsiprepXform);

rh_save_name = regexprep(outfile, '.nii', '_preproc.nii');
niftiWrite(Hip,rh_save_name)

%% With ANT 
% dtiRawAlignToT1 does not work because the segmentations are a matrix
% subset (nonpadded). SPM will take this information into account, simply
% run a SPM coregister estimate with LeadDBST1->qsiprep T1 and add the
% segmentations as extra images. Default coregister estimate settings
% appeared to work fine. Check results after. 

