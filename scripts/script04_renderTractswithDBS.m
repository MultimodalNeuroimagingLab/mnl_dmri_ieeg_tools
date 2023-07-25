%   Jordan Bilderbeek June 19 2023

%   This script is very similar to script03_renderTractswithElectrodes. We
%   load the tracks via DSI studio, then plot in a glass brain render.
%   However, because we are plotting DBS leads instead of sEEG we can
%   simplify the script a fair bit; we dont need to perform any complex
%   sorting.

%   Because we use the CTMR method to find the positions, we load XYZ
%   differently; we also assume the number of electrodes per DBS lead. 

%   The call to render_dbs_lead will also be different.

%% Initialize
close all;
clear all;

color={[0 .0706 .0980], [0 .3725 .4510], [.5804 .8235 .7412], [.9137 .8471 .6510], [0.9333 0.6078 0], [0.7922 0.4039 0.0078], [0.6824 0.1255 0.0706]};

setMyMatlabPaths;
addpath(genpath(pwd));
subnum=1;

[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

%% Load right tracks and files

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

ni_dwi = niftiRead(dwi_file);
[fg_fromtrk]=create_trkstruct(ni_dwi, Rtracks);

%% Plot right tracks
tic
figure(1);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); %Will need to do a surface of both sides
h=ieeg_RenderGifti(g); 


hold on
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end
hold off
disp(['Created track render in ' num2str(toc) ' seconds'])

%% Add ROI

hippocampus=niftiRead(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
renderROI(hippocampus, -32482); %-32482 is fs tag

%% Adding electrodes

elecmatrix=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix=table2array(elecmatrix);

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
render_dbs_lead(elecmatrix(9:12, :), .75, 46.6, 0)
%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
render_dbs_lead(elecmatrix(13:16, :), 1.5, 32.6, 0) 
h.FaceAlpha = 0.2;
loc_view(90,0)

addElectrode(elecmatrix(9:16, :), 'b', 0, .2, 9:16); %add blue rendering
custom_legend(Ltracks, color, sub_label) %add custom legend

%% Test code 
% load(fullfile(bids_path, 'BIDS_SubjectsRaw', 'derivatives', 'dsistudio', ['sub-' sub_label], 'Hippocampus_Right.nii.nii.gz.mat'));
% image=reshape(image, dimension);
% transformation=transf_mat(1:3, 4);
% transf_mat(1:3, 4)=0;
% D=diag(transf_mat);
% transformation=transformation .* D(1:3);
% 
% data=imwarp(image, affine3d(transf_mat));
% 
% patch(isocaps(data,.5),...
%     'FaceColor','interp','EdgeColor','none');
% p1 = patch(isosurface(data,.5),...
%     'FaceColor','red','EdgeColor','none');
% % 
% isonormals(data,p1)
% % axis vis3d tight
% % camlight left; 
% % colormap jet
% % lighting gouraud
