
%   Jordan Bilderbeek July 21 2023

%   Script to render one sEEG electrode lead with tracks. Prompts for user
%   input.
%
%
%   Future: allow comma sep values for input

%% Changeables / initialize
close all;

color={[0 .0706 .0980], [0 .3725 .4510], [.5804 .8235 .7412], [.9137 .8471 .6510], [0.9333 0.6078 0], [0.7922 0.4039 0.0078], [0.6824 0.1255 0.0706]};
setMyMatlabPaths;
addpath(genpath(pwd));
subnum=1;

[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

% Path to DSI studio - where your .trk files should be located
dsipath=fullfile(bids_path,['sub-' sub_label], 'dsi_studio');
[Ltracks, Rtracks]=getDSItracks(dsipath);
[Ltracks, Rtracks]=gz_unzip(Ltracks, Rtracks);

% Path to electrodes.tsv file
electrode_fn=fullfile(bids_path, ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']);
elStruct=sEEGsorter(electrode_fn);
[coords, tag]=plot_which_el(elStruct);

%% Load Files

%Load DWI file
dwi_file = fullfile(bids_path, ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
ni_dwi = niftiRead(dwi_file);
fg_fromtrk = [];

switch tag
    case 'L'
        [fg_fromtrk]=create_trkstruct(ni_dwi, Ltracks);
        g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii'));

    case 'R'
        [fg_fromtrk]=create_trkstruct(ni_dwi, Rtracks);
        g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii'));
end

%% Glass brain render

figure();
h = ieeg_RenderGifti(g); 
hold on

%Render all the DTI tracks. Color can be changed:
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end

render_dbs_lead(coords, .75, 46.6, 1)
addElectrode(coords, 'b', 0, 0.2)

