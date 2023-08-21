%   Jordan Bilderbeek June 19 2023; updated August 7
%
%   This script is used to generate glass brain figures (rendering tracks
%   with DBS) and can also be used on sEEG. We load the tracks and dwi
%   file, then plot the tracks using AFQ_RenderFibers. We can add specific
%   ROIs if needed, and render dbs/sEEG electrodes using the
%   render_dbs_lead function with specific parameters. 
%

%% Initialize
close all;
clear all;

%color={[0 .0706 .0980], [0 .3725 .4510], [.5804 .8235 .7412], [.9137 .8471
%.6510], [0.9333 0.6078 0], [0.7922 0.4039 0.0078], [0.6824 0.1255
%0.0706]}; %colormap for 8 colors

color={'#D00000', '#3185FC', '#FFBA08', '#5D2E8C', '#CBFF8C', '#46237A', '#8FE388', '#FF7B9C', '#1B998B', '#FF9B85'};
color=validatecolor(color, 'multiple');
setMyMatlabPaths;
addpath(genpath(pwd));
subnum=5;

[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

%% Load right tracks and files

%Get DSI paths, unzip them, and sort tracks based on l/r hemi
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

ni_dwi = niftiRead(dwi_file);
[fg_fromtrk]=create_trkstruct(ni_dwi, Rtracks);

%% Plot right tracks

%Load gifti and plot right tracks via AFQ_RenderFibers
figure(1);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); %Will need to do a surface of both sides
h=ieeg_RenderGifti(g); 

hold on
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color(ii, :),'newfig', false);
end
hold off

%% Add ROI

% Add specific ROIs and render them. We first read the niftis, then call
% renderROI function. We can pass specific segmentations (like -32482) if
% we want certain ROIs from a freesurfer volume being rendered in. 

hippocampus=niftiRead(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
hip=renderROI(hippocampus, color(7, :), -32482); %-32482 is freesurfer tag for hippocampus

r_AV=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAV.nii'));
av=renderROI(r_AV, color(8, :));

r_AD=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAD.nii'));
ad=renderROI(r_AD, color(9, :));

r_AM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAD.nii'));
am=renderROI(r_AM, color(10, :));


%% Adding electrodes

%Read in the electrode.tsv file, then assign elecmatrix to the xyz
%coordinates for each known contact
elecmatrix=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [elecmatrix.x elecmatrix.y elecmatrix.z];

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
render_dbs_lead(elecmatrix(9:12, :), .75, 46.6, 0)
%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
render_dbs_lead(elecmatrix(13:16, :), 1.5, 32.6, 0) 

addElectrode(elecmatrix(9:16, :), 'b', 0, .2, 9:16); %add blue rendering

%% Changing some plotting stuff
hip.FaceAlpha=.5;
av.FaceAlpha=.5;
ad.FaceAlpha=.5;
am.FaceAlpha=.5;
custom_legend(Rtracks, color, sub_label, 1) %add custom legend
loc_view(-90,0)
