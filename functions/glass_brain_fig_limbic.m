function glass_brain_fig_limbic(subnum)
%   Jordan Bilderbeek Aug 1
%
%   Creates glass brain rendering figure for one subject. Simply input
%   subnum and rendering will run. EST 20min/subject on an upsample factor
%   of 1000 (in render_dbs_lead) call. Ensure pathing is correct for your
%   subject. 
%
%   INPUTS:
%       a) subnum - numerical value (ex:1) for your subject number in
%       limbic_subject_library call. subnum is limited by the number of
%       subjects defined in limbic_subject_library function


%% glass_brain_fig_limbic

close all;
color={'#D00000', '#3185FC', '#FFBA08', '#5D2E8C', '#CBFF8C', '#46237A', '#8FE388', '#FF7B9C', '#1B998B', '#FF9B85'};
color=validatecolor(color, 'multiple');

setMyMatlabPaths;
addpath(genpath(pwd));
[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);

%% Load relevant files
switch sub_label
    case '06' %sub 06 is clinical axdti instead of diadem
        ni_dwi = niftiRead(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-axdti_space-T1w_desc-preproc_dwi.nii.gz']));
    otherwise
        ni_dwi = niftiRead(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']));
end
%% Prep data for statistics

[fg_fromtrk]=create_trkstruct(ni_dwi, tracks); %create fg_fromtrk structure with all tracks
[elStruct] = sEEGsorter(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']));

if tracks{1}(end-4)=='R'
    g = gifti(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); 
    invlead=0;
else
    g = gifti(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii')); 
    invlead=1;
end

elplot=regexprep(electrodes, '[\d"]', '');
elplot=unique(elplot);

%% Plot right tracks
tic
figure('units','normalized','outerposition',[0 0 1 1]);
h=ieeg_RenderGifti(g); 

hold on
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color(ii, :),'newfig', false);
end
hold off
disp(['Created track render in ' num2str(toc) ' seconds'])

%% Adding electrodes

tmp=[];
for ii=1:length(elStruct)
    names=elStruct(ii).name;
    tmp=[tmp;names];
end

for ii=1:length(elplot)
    ind=find(tmp==elplot(ii));
    render_dbs_lead(elStruct(ind).positions, 1, 20, invlead)
    addElectrode(elStruct(ind).positions, 'b', 0, .2); %add blue rendering
end
custom_legend(tracks, color, sub_label, 0) %add custom legend


loc_view(90,0)
savename=fullfile(bids_path,'derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_sEEGrender90.svg']);
saveas(gcf, savename)

loc_view(180,0)
savename=fullfile(bids_path,'derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_sEEGrender180.svg']);
saveas(gcf, savename)

loc_view(270,0)
savename=fullfile(bids_path,'derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_sEEGrender270.svg']);
saveas(gcf, savename)

loc_view(0,0)
savename=fullfile(bids_path,'derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_sEEGrender360.svg']);
saveas(gcf, savename)


end

