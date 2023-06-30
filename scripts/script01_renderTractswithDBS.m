%   Jordan Bilderbeek June 19 2023

%   This script is very similar to script01_renderTractswithElectrodes. We
%   load the tracks via DSI studio, then plot in a glass brain render.
%   However, because we are plotting DBS leads instead of sEEG we can
%   simplify the script a fair bit; we dont need to perform any complex
%   sorting. We first do the left hemisphere and then the right hemisphere.
%   

%   Because we use the CTMR method to find the positions, we load XYZ
%   differently; we also assume the number of electrodes per DBS lead. 

%   We also assume that the first half of the CTMR is left

%   The call to render_dbs_lead will also be different.

%% Initialize
close all;
clear all;

num_dbs_leads=4;
num_electrodes_per_lead=4;
lead_size=1; 

setMyMatlabPaths;
addpath(genpath(pwd)); 
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{1};

%% Load left tracks and files
tic;

%Change '' to use different tracks from DSI studio
all_trks = {'Uncinate_Fasciculus_R',...
    'Cingulum_Parahippocampal_R',...
    'Cingulum_Frontal_Parietal_R'};

%Load DWI file
dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_rec-none_run-01_space-T1w_desc-preproc_dwi.nii.gz']);
%dwi_file = fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);

ni_dwi = niftiRead(dwi_file);
fg_fromtrk = [];

for ss = 1:length(all_trks)
    trk_name = all_trks{ss};
    trk_file = fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], [trk_name '.trk']);

    if ~exist(trk_file, 'file')
        try
            trk_file_zip = fullfile(bids_path,['sub-' sub_label],'dsistudio',[trk_name '.trk.gz']);
            gunzip(trk_file_zip);
        catch
            warningMessage = sprintf('Warning: Zipped track file does not exist:\n%s', trk_file_zip);
        end
    end
    
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file);
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
        end

        % Create FG structure that can be visualized with AFQ tools
        % We apply a transofrmatrion matrix to make sure the tracks are in the
        % original dMRI space
        fg_fromtrk(ss).name = trk_name;
        fg_fromtrk(ss).colorRgb = [20 90 200];
        fg_fromtrk(ss).thickness = 0.5;
        fg_fromtrk(ss).visible = 1;
        fg_fromtrk(ss).seeds = [];
        fg_fromtrk(ss).seedRadius = 0;
        fg_fromtrk(ss).fibers = cell(length(tracks),1);
        for kk = 1:length(tracks)
            this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
            fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:);
            clear this_strm
        end
        clear header tracks
    else
        warningMessage = sprintf('Warning: Track file does not exist:\n%s', trk_file);
    return;
    end
end
disp(['Tracks loaded in ' num2str(toc) ' seconds'])
 
%% Load T1, gifti
tic;
 
t1_name = fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'anat',['sub-' sub_label '_desc-preproc_T1w.nii.gz']);
t1 = niftiRead(t1_name);
brighten_T1 = .5; % 1 for nothing, .5 for everything above 50% of maximum is white
t1.data(t1.data>brighten_T1*max(t1.data(:))) = brighten_T1*max(t1.data(:));
t1.sto_xyz = t1.qto_xyz;
t1.sto_ijk = t1.qto_ijk;

g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii')); %Will need to do a surface of both sides

disp(['Loaded T1, created gifti in ' num2str(toc) ' seconds'])

%% Glass brain render
tic

%figure();
h = ieeg_RenderGifti(g); 
hold on


lightH = camlight('right');

%Render all the DTI tracks. Color can be changed:
color={[.2 .7 .2], [.9 0 .6], [.9 .8 .5], [.5 .8 .9], [.6 .4 .2], [.4 .4 .6], [.2 .7 .2], [.9 0 .6], [.9 .8 .5], [.5 .8 .9], [.6 .4 .2], [.4 .4 .6]};
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end
disp(['Created track render in ' num2str(toc) ' seconds'])


%% Adding electrodes
load(fullfile(bids_path,'sourcedata',['sub-' sub_label],'positionsBrinkman', 'electrodes_loc1.mat')); %Will need to do a surface of both sides

init=length(elecmatrix)/2+1;
fin=init+num_electrodes_per_lead-1;
step=num_electrodes_per_lead;

for ii=1:num_dbs_leads/2
    render_dbs_lead(elecmatrix(init:fin, :), lead_size)
    init=init+step;
    fin=fin+step;
end
    
h.AmbientStrength=.3;
h.DiffuseStrength=.8;
h.FaceAlpha = 0.2;
light('Position', [270 30 0])

%% Now for the left side ... load right tracks

%Change '' to use different tracks from DSI studio
all_trks = {'Cingulum_Frontal_Parahippocampal_R',...
    'Fornix_R',...
    'Cingulum_Parahippocampal_Parietal_R',...
    'Cingulum_Parahippocampal_R',...
    'Cingulum_Frontal_Parietal_R',...
    'Cingulum_Parolfactory_R'};

fg_fromtrk = [];
for ss = 1:length(all_trks)
    trk_name = all_trks{ss};
    trk_file = fullfile(bids_path,['sub-' sub_label],'dsi_studio',[trk_name '.trk']);

    if ~exist(trk_file, 'file')
        try
            trk_file_zip = fullfile(bids_path,['sub-' sub_label],'dsi_studio',[trk_name '.trk.gz']);
            gunzip(trk_file_zip);
        catch
            warningMessage = sprintf('Warning: Zipped track file does not exist:\n%s', trk_file_zip);
        end
    end
    
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file);
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
        end

        % Create FG structure that can be visualized with AFQ tools
        % We apply a transofrmatrion matrix to make sure the tracks are in the
        % original dMRI space
        fg_fromtrk(ss).name = trk_name;
        fg_fromtrk(ss).colorRgb = [20 90 200];
        fg_fromtrk(ss).thickness = 0.5;
        fg_fromtrk(ss).visible = 1;
        fg_fromtrk(ss).seeds = [];
        fg_fromtrk(ss).seedRadius = 0;
        fg_fromtrk(ss).fibers = cell(length(tracks),1);
        for kk = 1:length(tracks)
            this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
            fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:);
            clear this_strm
        end
        clear header tracks
    else
        warningMessage = sprintf('Warning: Track file does not exist:\n%s', trk_file);
    return;
    end
end

g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); %Will need to do a surface of both sides

%% Load right tracks
tic

figure();
h = ieeg_RenderGifti(g); 
hold on

lightH = camlight('left');

%Render all the DTI tracks. Color can be changed:
color={[.2 .7 .2], [.9 0 .6], [.9 .8 .5], [.5 .8 .9], [.6 .4 .2], [.4 .4 .6], [.2 .7 .2], [.9 0 .6], [.9 .8 .5], [.5 .8 .9], [.6 .4 .2], [.4 .4 .6]};
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end
disp(['Created track render in ' num2str(toc) ' seconds'])
    

%% Adding electrodes

init=1;
fin=init+num_electrodes_per_lead;
step=num_electrodes_per_lead;

for ii=1:num_dbs_leads/2
    render_dbs_lead(elecmatrix.elecmatrix(init:fin, :), lead_size)
    init=init+step;
    fin=fin+step;
end
    
h.AmbientStrength=.3;
h.DiffuseStrength=.8;
h.FaceAlpha = 0.2;
light('Position', [90 30 0])