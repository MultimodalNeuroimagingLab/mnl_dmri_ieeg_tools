
%   Jordan Bilderbeek July 21 2023

%   Script to render one sEEG electrode lead with tracks. Prompts for user
%   input.
%
%   Future: allow comma sep values for input

%% Changeables / initialize
close all;

color={[0 .0706 .0980], [0 .3725 .4510], [.5804 .8235 .7412], [.9137 .8471 .6510], [0.9333 0.6078 0], [0.7922 0.4039 0.0078], [0.6824 0.1255 0.0706]};
setMyMatlabPaths;
addpath(genpath(pwd));
subnum=6;

[sub_label,bids_path, ~, tracks] = limbic_subject_library(subnum);

% Path to electrodes.tsv file
electrode_fn=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']);
elStruct=sEEGsorter(electrode_fn);
[coords, tag]=plot_which_el(elStruct);

%% Load Files

%Load DWI file 
switch sub_label
    case '06'
        dwi_file = fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-axdti_space-T1w_desc-preproc_dwi.nii.gz']);
    otherwise
        dwi_file = fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);

end
ni_dwi = niftiRead(dwi_file);
fg_fromtrk = [];
figure();
switch tag % -32676 is L hippocampus; -32482 is R hippocampus
    case 'L'
        [fg_fromtrk]=create_trkstruct(ni_dwi, tracks);
        g = gifti(fullfile(bids_path,'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii'));
        hippocampus=niftiRead(fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
        h = ieeg_RenderGifti(g); 
        hold on
        hip=renderROI(hippocampus, color{7}, -32676);

    case 'R'
        [fg_fromtrk]=create_trkstruct(ni_dwi, tracks);
        g = gifti(fullfile(bids_path,'derivatives', 'qsiprep',['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii'));
        hippocampus=niftiRead(fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
        h = ieeg_RenderGifti(g); 
        hold on
        hip=renderROI(hippocampus, color{7}, -32482);
end

%% Render tracks and plot leads

%Render all the DTI tracks. Color can be changed:
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end

for ii=1:length(coords)
    %render_dbs_lead(coords(ii).positions, .75, 46.6, 0)
    addElectrode(coords(ii).positions, 'b', 0, 0.2)
end

hip.FaceAlpha=.5;
