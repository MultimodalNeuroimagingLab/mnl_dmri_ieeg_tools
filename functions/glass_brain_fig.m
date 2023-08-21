function glass_brain_fig(subnum)
%   Jordan Bilderbeek August 1; updated August 7
%
%   Creates glass brain rendering figure for one subject. Simply input
%   subnum and rendering will run. EST 20min/subject on an upsample factor
%   of 1000 (in render_dbs_lead) call. Ensure pathing is correct for your
%   subject. Essentially the same as script04 but as a function.
%
%   INPUTS:
%       a) subnum - numerical value (ex:1) for your subject number in
%       dmri_subject_list call. subnum is limited by the number of subjects
%       defined in dmri_subject_list function

%% glass_brain_fig

close all;

%Set track colors
color={'#D00000', '#3185FC', '#FFBA08', '#5D2E8C', '#CBFF8C', '#46237A', '#8FE388', '#FF7B9C', '#1B998B', '#000000'};
color=validatecolor(color, 'Multiple');

%Set paths, get bids path and subject label
setMyMatlabPaths;
addpath(genpath(pwd));
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

%Set DSI path and get L and R tracks, and unzip them if necessary
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

%Load nifti and create trk struct
ni_dwi = niftiRead(dwi_file);
[fg_fromtrk]=create_trkstruct(ni_dwi, Rtracks);

%% Plot right tracks
tic
figure('units','normalized','outerposition',[0 0 1 1]);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.R.surf.gii')); %Will need to do a surface of both sides
h=ieeg_RenderGifti(g); 

hold on
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color(ii, :),'newfig', false);
end
hold off
disp(['Created track render in ' num2str(toc) ' seconds'])

%% Add ROI

%Load ROIs and render them
hippocampus=niftiRead(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
hip=renderROI(hippocampus, color(7, :), -32482); %-32482 is fs tag

r_AV=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAV.nii'));
av=renderROI(r_AV, color(8, :));

r_AD=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAD.nii'));
ad=renderROI(r_AD, color(9, :));

r_AM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rAM.nii'));
am=renderROI(r_AM, color(10, :));

%r_CL=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rCL.nii'));
%cl=renderROI(r_CL, color(8, :));

%r_CM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'rCM.nii'));
%cm=renderROI(r_CM, color(9, :));


%% Adding electrodes

%Load electrode TSV with contact location information
electrode_tsv=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
electrodes={'RA1', 'RA2', 'RA3', 'RA4'};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.label,electrodes), :), .75, 46.6, 0)

%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
electrodes={'RH1', 'RH2', 'RH3', 'RH4'};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.label,electrodes), :), 1.5, 32.6, 0) 

%Add sphere around contacts to illustrate current spread
electrodes={'RA1', 'RA2', 'RA3', 'RA4', 'RH1', 'RH2', 'RH3', 'RH4' };
addElectrode(elecmatrix(ismember(electrode_tsv.label,electrodes), :), 'b', 0, .2); %add blue rendering

%Change the FaceAlpha of all the rois
hip.FaceAlpha=.5;
av.FaceAlpha=.5;
ad.FaceAlpha=.5;
am.FaceAlpha=.5;
%cl.FaceAlpha=.5;
%cm.FaceAlpha=.5;

%Add legend
custom_legend(Rtracks, color, sub_label, 1) 

%Rotate the brain in different views and save the output as a .svg file
loc_view(90, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL90_render_R.svg']);
saveas(gcf, savename)

loc_view(180, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL180_render_R.svg']);
saveas(gcf, savename)

loc_view(270, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL270_render_R.svg']);
saveas(gcf, savename)

loc_view(0, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL0_render_R.svg']);
saveas(gcf, savename)

%% Now for the left side - repeat from above
close all;

%Create track structure, now for the left side. Dont need to reload dwi
%image or gather L tracks as already done. 
[fg_fromtrk]=create_trkstruct(ni_dwi, Ltracks);

%% Plot left tracks
tic
figure('units','normalized','outerposition',[0 0 1 1]);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii')); %Will need to do a surface of both sides
h=ieeg_RenderGifti(g); 

hold on
for ii=1:length(fg_fromtrk)
    AFQ_RenderFibers(fg_fromtrk(ii),'numfibers',300,'color',color(ii, :),'newfig', false);
end
hold off
disp(['Created track render in ' num2str(toc) ' seconds'])

%% Add ROI

%Plot ROI, now for left side
hippocampus=niftiRead(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_preproc.nii.gz' ));
hip=renderROI(hippocampus, color(7, :), -32676); %left fs tag

l_AV=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lAV.nii'));
av=renderROI(l_AV, color(8, :));

l_AD=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lAD.nii'));
ad=renderROI(l_AD, color(9, :));

l_AM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lAM.nii'));
am=renderROI(l_AM, color(10, :));

%l_CL=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lCL.nii'));
%cl=renderROI(l_CL, color(8, :));

%l_CM=niftiRead(fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'leaddbsinqsi', ['sub-' sub_label], 'lCM.nii'));
%cm=renderROI(l_CM, color(9, :));

%% Adding electrodes

electrode_tsv=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
electrodes={'LA1', 'LA2', 'LA3', 'LA4'};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.label,electrodes), :), .75, 46.6, 1)

%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
electrodes={'LH1', 'LH2', 'LH3', 'LH4'};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.label,electrodes), :), 1.5, 32.6, 1) 
loc_view(90,0)

electrodes={'LA1', 'LA2', 'LA3', 'LA4', 'LH1', 'LH2', 'LH3', 'LH4' };
addElectrode(elecmatrix(ismember(electrode_tsv.label,electrodes), :), 'b', 0, .2); %add blue rendering

%Change face alpha of ROI
hip.FaceAlpha=.5;
av.FaceAlpha=.5;
ad.FaceAlpha=.5;
am.FaceAlpha=.5;
%cl.FaceAlpha=.5;
%cm.FaceAlpha=.5;

custom_legend(Ltracks, color, sub_label, 1) %add custom legend

%Rotate and save as .svg file in appropriate location
loc_view(90, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL90_notrkrender_L.svg']);
saveas(gcf, savename)

loc_view(180, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL180_notrkrender_L.svg']);
saveas(gcf, savename)

loc_view(270, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL270_notrkrender_L.svg']);
saveas(gcf, savename)

loc_view(0, 0)
savename=fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'figs', ['sub-' sub_label], ['sub-' sub_label '_glassbrain_CMCL0_notrkrender_L.svg']);
saveas(gcf, savename)

end

