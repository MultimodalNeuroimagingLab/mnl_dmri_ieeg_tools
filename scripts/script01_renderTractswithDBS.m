%   Jordan Bilderbeek June 19 2023

%   This script is very similar to script01_renderTractswithElectrodes. We
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

num_dbs_leads=4;
num_electrodes_per_lead=4;
lead_size=1; 
color={[0 .0706 .0980], [0 .3725 .4510], [.5804 .8235 .7412], [.9137 .8471 .6510], [0.9333 0.6078 0], [0.7922 0.4039 0.0078], [0.6824 0.1255 0.0706]};

setMyMatlabPaths;
addpath(genpath(pwd));
subnum=3;

[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

%% Load right tracks and files
tic;

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
fg_fromtrk = [];

for ss = 1:length(Rtracks)
    trk_file = Rtracks{ss};
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
        trk_name=regexp(trk_file, '/', 'split');
        fg_fromtrk(ss).name = trk_name{end};
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

%% Plot right tracks
tic
figure(1);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); %Will need to do a surface of both sides
h = ieeg_RenderGifti(g); 

hold on
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end
hold off
disp(['Created track render in ' num2str(toc) ' seconds'])


%% Adding electrodes
%load(fullfile(bids_path,'sourcedata',['sub-' sub_label],'positionsBrinkman', 'electrodes_loc1.mat')); %Will need to do a surface of both sides

electrodepositions = fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']);
elecmatrix=readtable(electrodepositions, 'FileType', 'text', 'Delimiter', '\t');
elecmatrix=table2array(elecmatrix);

init=length(elecmatrix)/2+1;
fin=init+num_electrodes_per_lead-1;
step=num_electrodes_per_lead;

invlead=0;
for ii=1:num_dbs_leads/2
    disp(['Creating Right lead number ' num2str(ii)]);
    render_dbs_lead(elecmatrix(init:fin, :), lead_size, invlead)
    init=init+step;
    fin=fin+step;
end   
h.AmbientStrength=.3;
h.DiffuseStrength=.8;
h.FaceAlpha = 0.2;
view(-127,-12)
lightangle(-127, -12)

tmpmat=elecmatrix(9:16, :);
camlight right
addElectrode(tmpmat, 2, 'b', 0, .2);
custom_legend(Ltracks, color, sub_label)
montage3;

% %% Add ROI
% 
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
% p1.XData=p1.XData + transformation(1);
% p1.YData=p1.YData + transformation(2);
% p1.ZData=p1.ZData + transformation(3);
% 
% isonormals(data,p1)
% axis vis3d tight
% camlight left; 
% colormap jet
% lighting gouraud


out=input('Continue plotting? (y/n)', "s");
if out=='n'
    return
end

%% Now for the left side ... load left tracks

fg_fromtrk = [];
for ss = 1:length(Ltracks)
    trk_file = Ltracks{ss};
    
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file);
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
        end

        trk_name=regexp(trk_file, '/', 'split');
        fg_fromtrk(ss).name = trk_name{end};
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

%% Plot left tracks
tic

figure(1);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii')); %Will need to do a surface of both sides
h=ieeg_RenderGifti(g); 
hold on

for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end
disp(['Created track render in ' num2str(toc) ' seconds'])
    

%% Adding electrodes

init=1;
fin=num_electrodes_per_lead;
step=num_electrodes_per_lead;

invlead=1;
for ii=1:num_dbs_leads/2
    disp(['Creating left lead number ' num2str(ii)])
    render_dbs_lead(elecmatrix(init:fin, :), lead_size, invlead)
    init=init+step;
    fin=fin+step;
end
    
h.AmbientStrength=.3;
h.DiffuseStrength=.8;
h.FaceAlpha = 0.2;
light('Position', [90 30 0])