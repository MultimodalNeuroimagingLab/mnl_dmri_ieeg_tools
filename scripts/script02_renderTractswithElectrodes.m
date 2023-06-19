
%   Jordan Bilderbeek June 13 2023

%   Re-write of script01_renderTractswithElectrodes; main purpose to
%   simplify plotting. We also re-write the
%   electrode selection using new function. 

%   Important things are 1) lead=1 or lead=n; if equal to 1 then we are
%   plotting the whole lead and 2) the retrieve_row_key_letter function,
%   can either use 'pall' for plot all or some other 4 character string
%   like 'cing' to find the cingulum electrodes. Works well after we
%   identify the tracks from DSI and upload them, we can find related
%   electrodes in the destrieux label. 

%% Changeables / initialize
close all;

setMyMatlabPaths;
addpath(genpath(pwd)); 
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{1};

%Change '' to use different tracks from DSI studio
all_trks = {'Cingulum_Frontal_Parahippocampal_L',...
    'Fornix_L',...
    'Cingulum_Parahippocampal_Parietal_L',...
    'Cingulum_Parahippocampal_L',...
    'Cingulum_Frontal_Parietal_L',...
    'Cingulum_Parolfactory_L'};

electrodes_tsv = fullfile(bids_path,['sub-' sub_label],['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']);
loc_info = readtable(electrodes_tsv,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});

%Change '' text to search for 4 character ROI based on destriux label. Ex: 'cing' for
%cingulum (must exist as a tag within the table). Can alternatively provide
%'pall' to plot all electrodes/leads.
row=retrieve_row_key_letter('ippo', loc_info); 
elecmatrix = [loc_info.x loc_info.y loc_info.z];

lead=1; %Determine if we want to plot the whole lead or just electrodes. If lead=1 then whole lead.

%Calculate the mean location to determine which hemisphere the electrodes
%are placed in (assumption)
elecpos=mean(rmmissing(loc_info.x));

disp('Initialized and selected ROI');

%% Load Files
tic;

%Load DWI file
dwi_file = fullfile(bids_path, ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
ni_dwi = niftiRead(dwi_file);
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
disp(['Tracks loaded in ' num2str(toc) ' seconds'])
 
%% Load T1, gifti
tic;
 
t1_name = fullfile(bids_path,['sub-' sub_label],'anat',['sub-' sub_label '_desc-preproc_T1w.nii.gz']);
t1 = niftiRead(t1_name);
brighten_T1 = .5; % 1 for nothing, .5 for everything above 50% of maximum is white
t1.data(t1.data>brighten_T1*max(t1.data(:))) = brighten_T1*max(t1.data(:));
t1.sto_xyz = t1.qto_xyz;
t1.sto_ijk = t1.qto_ijk;

% Determine either L or R...?
if elecpos < 0
    g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii'));
else
    g = gifti(fullfile(bids_path,['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii'));
end
disp(['Loaded T1, created gifti in ' num2str(toc) ' seconds'])

%% Glass brain render
tic

figure();
h = ieeg_RenderGifti(g); 
hold on

% Similar to above
if elecpos < 0
    lightH = camlight('right');
else
    lightH = camlight('left');
end

%Render all the DTI tracks. Color can be changed:
color={[.2 .7 .2], [.9 0 .6], [.9 .8 .5], [.5 .8 .9], [.6 .4 .2], [.4 .4 .6], [.2 .7 .2], [.9 0 .6], [.9 .8 .5], [.5 .8 .9], [.6 .4 .2], [.4 .4 .6]};
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color{ii},'newfig', false);
end
disp(['Created track render in ' num2str(toc) ' seconds'])


%% Adding electrodes

if lead==1
    disp('Plotting whole leads: finding electrode components and fitting spline')
    electrode_list=retrieve_row_key_letter_v2(loc_info, row);
    electrode_list=unique(electrode_list, 'stable');
    
    % Sorter; can be integrated into retrieve row if we want. Or not ...
    currentPrefix='';
    electrodelist={};
    tempCellArray={};
    for ii=1:numel(electrode_list)
        prefix=regexprep(electrode_list{ii}, '[\d"]', '');
        if ~strcmp(prefix, currentPrefix)
            if ~isempty(tempCellArray)
                electrodelist{end+1}=tempCellArray;
            end
            currentPrefix=prefix;
            tempCellArray={};
        end
        tempCellArray{end+1}=electrode_list{ii};
    end
    electrodelist{end+1}=tempCellArray;
       
    for ii=1:size(electrodelist, 2)
        tic
        els_plot=electrodelist{ii};
        render_seeg_lead(elecmatrix(ismember(loc_info.name, els_plot'), :), 1.5, 2);
        disp(['Lead ' num2str(ii) ' plotted in ' num2str(toc) ' seconds']); 
    end
       
else
    disp('Plotting each electrode individually')
    
    %If on the off chance the destrieux label is not good enough for
    %finding the electrodes we are interested in, simply override row
    %variable with a cell array of 
    
%     row={'EL1', 'EL2', 'EL3'};
%     addElectrode(elecmatrix(ismember(loc_info.name, row), :), 3, 'b', 2)
    alpha=.4;
    addElectrode(elecmatrix(ismember(loc_info.name, table2array(row)), :), 1, 'b', 0, alpha)
    alpha=.3;
    addElectrode(elecmatrix(ismember(loc_info.name, table2array(row)), :), 2, 'c', 0, alpha)
end

h.AmbientStrength=.3;
h.DiffuseStrength=.8;
h.FaceAlpha = 0.2;
light('Position', [270 30 0])
%% Extra visualization

orbit=0;
if orbit==1
    rotationangle=1;
    numIterations=360 ;
    for i=1:numIterations
        camorbit(rotationangle, 0, 'data')
        pause(.1)
        drawnow;
    end
end


