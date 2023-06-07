

setMyMatlabPaths;

addpath(genpath(pwd)); 

%% load subject - all tracks

[my_subject_labels,bids_path] = dmri_subject_list();

sub_label = my_subject_labels{2};

dwi_file = fullfile(bids_path,'derivatives','qsiprep',['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
ni_dwi = niftiRead(dwi_file);
% figure,imagesc(ni_dwi.data(:,:,50,1)) % sanity check

% these are the names that were saved, in trk,gz format, unzipped manually ot .trk....
all_trks = {'Arcuate_Fasciculus_R',...
    'Parietal_Aslant_Tract_R',...
    'Vertical_Occipital_Fasciculus_R',...
    'Middle_Longitudinal_Fasciculus_R'};

fg_fromtrk = [];

for ss = 1:length(all_trks)

    tkr_name = all_trks{ss};
    % this is where the output from DSI studio
    trk_file = fullfile(bids_path,'derivatives','qsiprep',['sub-' sub_label],'dsi_studio',[tkr_name '.trk']);

    [header,tracks] = trk_read(trk_file);

    % correct header
    header.vox_to_ras = ni_dwi.qto_xyz;

    transf_mat = header.vox_to_ras;
    for ii = 1:3
        transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
    end

    % create fg structure that can be visualized with AFQ tools
    % apply transofrmatrion matrix to make sure the tracks are in the
    % original dMRI space
    fg_fromtrk(ss).name = tkr_name;
    fg_fromtrk(ss).colorRgb = [20 90 200];
    fg_fromtrk(ss).thickness = 0.5;
    fg_fromtrk(ss).visible = 1;
    fg_fromtrk(ss).seeds = [];
    fg_fromtrk(ss).seedRadius = 0;
    fg_fromtrk(ss).fibers = cell(length(tracks),1);
    for kk = 1:length(tracks)
        this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
    %     this_strm = dwi.qto_xyz*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
        fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:);
        clear this_strm
    end
    clear header tracks
end

%% Load electrodes, T1, gifti

electrodes_tsv = fullfile(bids_path,['sub-' sub_label],'ses-ieeg01','ieeg',['sub-' sub_label '_ses-ieeg01_electrodes.tsv']);
loc_info = readtable(electrodes_tsv,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});
elecmatrix = [loc_info.x loc_info.y loc_info.z];
 
t1_name = fullfile(bids_path,'derivatives','qsiprep',['sub-' sub_label],'anat',['sub-' sub_label '_desc-preproc_T1w.nii.gz']);
% t1 = readFileNifti(t1_name);
t1 = niftiRead(t1_name);
brighten_T1 = .5; % 1 for nothing, .5 for everything above 50% of maximum is white
t1.data(t1.data>brighten_T1*max(t1.data(:))) = brighten_T1*max(t1.data(:));
t1.sto_xyz = t1.qto_xyz;
t1.sto_ijk = t1.qto_ijk;

g = gifti(fullfile(bids_path,'derivatives','qsiprep',['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii'));

%% Right implant

% fiber names
% all_trks = {'Arcuate_Fasciculus_R',...
%     'Parietal_Aslant_Tract_R',...
%     'Vertical_Occipital_Fasciculus_R',...
%     'Middle_Longitudinal_Fasciculus_R'};

AFQ_RenderFibers(fg_fromtrk(1),'numfibers',300,'color',[.5 .8 .9]);%,'newfig',false);
AFQ_RenderFibers(fg_fromtrk(2),'numfibers',300,'color',[.9 0 .6],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(3),'numfibers',300,'color',[.9 .8 .5],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(4),'numfibers',300,'color',[.2 .7 .2],'newfig',false);

AFQ_AddImageTo3dPlot(t1,[10, 0, 0],[],0)

% ieeg_elAdd(elecmatrix,[.99 .99 .99],20)
% ieeg_elAdd(elecmatrix,'k',10)

view(90,30)
axis image
lightH = camlight('right');

els_plot = {'RT1','RJ7','RJ8'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.99 .99 .99],40)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'k',30)

els_plot = {'ROC1','ROC5','RT1'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.99 .99 .99],20)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'k',15)

els_plot = {'RP11','RP12','RP13'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.99 .99 .99],20)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'r',15)

els_plot = {'RJ7','RJ8'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.99 .99 .99],20)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'g',15)


ieeg_elAdd(elecmatrix,'w',20)

%% with glass render

figure
h = ieeg_RenderGifti(g);
h.FaceAlpha = 0.2;
hold on

AFQ_RenderFibers(fg_fromtrk(1),'numfibers',300,'color',[.2 .7 .2],'newfig',false);
% AFQ_RenderFibers(fg_fromtrk(2),'numfibers',300,'color',[.9 0 .6],'newfig',false);
% AFQ_RenderFibers(fg_fromtrk(3),'numfibers',300,'color',[.9 .8 .5],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(4),'numfibers',300,'color',[.5 .8 .9],'newfig',false);

% AFQ_AddImageTo3dPlot(t1,[10, 0, 0],[],0)

% ieeg_elAdd(elecmatrix,[.99 .99 .99],20)
% ieeg_elAdd(elecmatrix,'k',10)

view(100,10)
lightH = camlight('right');

els_plot = {'RT1','RJ7','RJ8'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'k',40)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'g',30)

els_plot = {'ROC1','ROC5','RT1'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'k',40)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'g',30)

% els_plot = {'RP11','RP12','RP13'};
% ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.99 .99 .99],40)
% ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'k',30)

% els_plot = {'RJ7','RJ8'};
% ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.99 .99 .99],40)
% ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),'k',30)


els_plot = {'RZ9','RZ10','RC7'};
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[.1 .1 .1],40)
ieeg_elAdd(elecmatrix(ismember(loc_info.name,els_plot),:),[0 .2 1],30)

