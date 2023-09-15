
%   Jordan Bilderbeek July 21 2023
%
%   Script to render multiplel sEEG electrode leads with tracks. Prompts for user
%   input. Allows for comma sep values, ex: 'RB, RC, LA.' Mainly used
%   within the limbic project (not RCpS)
%



%% Changeables / initialize
close all;

color={'#D00000', '#3185FC', '#FFBA08', '#5D2E8C', '#CBFF8C', '#46237A', '#8FE388', '#FF7B9C', '#1B998B', '#FF9B85'};
color=validatecolor(color, 'multiple');
setMyMatlabPaths;
addpath(genpath(pwd));
subnum=7;

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
set(gcf, 'Color', 'k');

switch tag % -17 is L hippocampus; -53 is R hippocampus
    case 'L'
        [fg_fromtrk]=create_trkstruct(ni_dwi, tracks);
        g = gifti(fullfile(bids_path,'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii'));
        h = ieeg_RenderGifti(g); 
        
        for ii=1:length(fg_fromtrk)
            hold on;
            AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',600,'color',color(ii, :),'newfig', false);
        end

        try
            %hippocampus=niftiRead(fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'rhippocampus_amygdala_lr_preproc.nii' ));
            hold on
            hip=renderROI(hippocampus, color(7, :), 17);
        catch
            disp('No hippocampus file')
        end

    case 'R'
        [fg_fromtrk]=create_trkstruct(ni_dwi, tracks);
        g = gifti(fullfile(bids_path,'derivatives', 'qsiprep',['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii'));
        h = ieeg_RenderGifti(g); 
        
        for ii=1:length(fg_fromtrk)
            hold on;
            AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',600,'color',color(ii, :),'newfig', false);
        end
        
        try
            %hippocampus=niftiRead(fullfile(bids_path,'derivatives', 'freesurfer', ['sub-' sub_label], 'mri', 'rhippocampus_amygdala_lr_preproc.nii' ));
            hold on
            hip=renderROI(hippocampus, color(7, :), 53);
        catch
            disp('No hippocampus file')
        end
end

%% Plot leads
% for ii=1:length(coords)
%     render_dbs_lead(coords(ii).positions, .75, 46.6, 0)
%     addElectrode(coords(ii).positions, 'b', 0, 0.2)
% end

try
    hip.FaceAlpha=.5;
catch
    disp('No hip alpha to change')
end

elec=elStruct(16).positions(3, :);
%fib=trk_concat(fg_fromtrk, elec, 'Fornix', 'Cingulum_Parolfactory');
nonempty_fib=~cellfun('isempty', fib);
fib=fib(nonempty_fib);
loc_view(270, 0)
dynamic_tractography(fib(1:20:end), elec, 10)
