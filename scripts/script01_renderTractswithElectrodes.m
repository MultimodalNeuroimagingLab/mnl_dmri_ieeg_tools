
setMyMatlabPaths;
addpath(genpath(pwd)); 

%% load subject - all tracks

[my_subject_labels,bids_path] = dmri_subject_list();

sub_label = my_subject_labels{1};

dwi_file = fullfile(bids_path, ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
ni_dwi = niftiRead(dwi_file);
% figure,imagesc(ni_dwi.data(:,:,50,1)) % sanity check

% these are the names that were saved, in trk,gz format, unzipped manually ot .trk....


all_trks = {'Cingulum_Frontal_Parahippocampal_L',...
    'Fornix_L',...
    'Cingulum_Parahippocampal_Parietal_L',...
    'Cingulum_Parahippocampal_L',...
    'Cingulum_Frontal_Parietal_L',...
    'Cingulum_Parolfactory_L'};

fg_fromtrk = [];

for ss = 1:length(all_trks)

    trk_name = all_trks{ss};
    % this is where the output from DSI studio enters; we unzip in Matlab
 
    trk_file_zip = fullfile(bids_path,['sub-' sub_label],'dsi_studio',[trk_name '.trk.gz']);
    gunzip(trk_file_zip);
    trk_file = fullfile(bids_path,['sub-' sub_label],'dsi_studio',[trk_name '.trk']);
    
    if exist(trk_file, 'file')

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
        fg_fromtrk(ss).name = trk_name;
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
    else
        warningMessage = sprintf('Warning: file does not exist:\n%s', trk_file);
    return;
    end
 
end

%% Load electrodes, T1, gifti

electrodes_tsv = fullfile(bids_path,['sub-' sub_label],['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']);
loc_info = readtable(electrodes_tsv,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});
elecmatrix = [loc_info.x loc_info.y loc_info.z];
 
t1_name = fullfile(bids_path,['sub-' sub_label],'anat',['sub-' sub_label '_desc-preproc_T1w.nii.gz']);
% t1 = readFileNifti(t1_name);
t1 = niftiRead(t1_name);
brighten_T1 = .5; % 1 for nothing, .5 for everything above 50% of maximum is white
t1.data(t1.data>brighten_T1*max(t1.data(:))) = brighten_T1*max(t1.data(:));
t1.sto_xyz = t1.qto_xyz;
t1.sto_ijk = t1.qto_ijk;

g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii'));
%g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii'));

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
AFQ_RenderFibers(fg_fromtrk(5),'numfibers',300,'color',[.9 .8 .5],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(6),'numfibers',300,'color',[.2 .7 .2],'newfig',false);

AFQ_AddImageTo3dPlot(t1,[1, 0, 0],[],0)

% ieeg_elAdd(elecmatrix,[.99 .99 .99],20)
% ieeg_elAdd(elecmatrix,'k',10)

view(270,30)
axis image
lightH = camlight('right');

specific_electrodes=0;

if specific_electrodes==1
    
    %if specific_electrodes==1 we can manually input which
    %electrodes we want to plot based on the x,y,z, data; if equal to zero
    %plot all
    
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

else
    ieeg_elAdd(elecmatrix,'w',20)
end

%% with glass render

figure
%subplot(1,2,1)
h = ieeg_RenderGifti(g); %ensure that g is the correct side (either R/L depending on tract)
h.FaceAlpha = 0.2;
hold on

AFQ_RenderFibers(fg_fromtrk(1),'numfibers',300,'color',[.2 .7 .2],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(2),'numfibers',300,'color',[.9 0 .6],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(3),'numfibers',300,'color',[.9 .8 .5],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(4),'numfibers',300,'color',[.5 .8 .9],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(5),'numfibers',300,'color',[.9 .8 .5],'newfig',false);
AFQ_RenderFibers(fg_fromtrk(6),'numfibers',300,'color',[.5 .8 .9],'newfig',false);

% AFQ_AddImageTo3dPlot(t1,[10, 0, 0],[],0)

% ieeg_elAdd(elecmatrix,[.99 .99 .99],20)
% ieeg_elAdd(elecmatrix,'k',10)

view(100,10)
lightH = camlight('right');

if specific_electrodes==1
    
    %if specific_electrodes==1 we can manually input which
    %electrodes we want to plot based on the x,y,z, data; if equal to zero
    %plot all
    
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

else
    %ieeg_elAdd(elecmatrix,'k',20)
end


%% Partitioning and creating 3D render of electrodes

wholelead=1;
row=retrieve_row_key_letter('campus', loc_info); %perform row search based on roi of interest
if wholelead==1
    electrode_list=retrieve_row_by_labels(row, loc_info);
   

    for ii=1:size(electrode_list, 2)
        tags=table2array(electrode_list(1,:));
        [uniqueData, ~, idx]=unique(tags, 'stable');
        counts=histc(idx, 1:numel(uniqueData));
        duplicates=uniqueData(counts>1);
        if isempty(duplicates)
            break;
        end
        locations=find(strcmp(tags, duplicates{ii}));
        electrode_list(:, locations(2:end))=[];
    end
    

    %plot each lead and fit a spline throught the electrodes
    for ii=1:size(electrode_list, 2)

        els_plot=table2cell(electrode_list(:,ii));
        %addElectrode(elecmatrix(ismember(loc_info.name, els_plot'), :), 3, color{ii}, 1)
        render_dbs_lead(elecmatrix(ismember(loc_info.name, els_plot'), :), 1.5, 2);
    end
else
    %plot electrodes individually
    addElectrode(elecmatrix(ismember(loc_info.name, table2array(row)), :), 3, 'b', 2)
    
end



