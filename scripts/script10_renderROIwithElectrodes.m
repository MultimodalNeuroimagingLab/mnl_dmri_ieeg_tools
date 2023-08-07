setMyMatlabPaths;
addpath(genpath(pwd));
subnum=1;

[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

close all

%% Plot 
figure(1);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); %Will need to do a surface of both sides
h = ieeg_RenderGifti(g); 

%% Plot ROI

%hippocampus=niftiRead(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
%renderROI(hippocampus, -32482);
% -32676 is L hippocampus; -32482 is R hippocampus

R_AD=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbs', ['sub-' sub_name], 'atlases', 'Morel_medium_5vox', 'rh', 'AD_preproc.nii')); 


%% Adding electrodes

elecmatrix=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [elecmatrix.x elecmatrix.y elecmatrix.z];

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
render_dbs_lead(elecmatrix(9:12, :), .75, 46.6, 0)
%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
render_dbs_lead(elecmatrix(13:16, :), 1.5, 32.6, 0) 
loc_view(90,0)

addElectrode(elecmatrix(9:16, :), 'b', 0, .2, [13 14 15 16 9 10 11 12]); %add blue rendering