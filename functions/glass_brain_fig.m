function glass_brain_fig(subnum)

color={[0 .0706 .0980], [0 .3725 .4510], [.5804 .8235 .7412], [.9137 .8471 .6510], [0.9333 0.6078 0], [0.7922 0.4039 0.0078], [0.6824 0.1255 0.0706]};

setMyMatlabPaths;
addpath(genpath(pwd));
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

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

electrode_tsv=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
electrodes={''};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.name,electrodes{ii})), .75, 46.6, 0)
%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
electrodes={''};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.name,electrodes{ii})), 1.5, 32.6, 0) 
h.FaceAlpha = 0.2;
loc_view(90,0)

addElectrode(elecmatrix(9:16, :), 'b', 0, .2, 9:16); %add blue rendering
custom_legend(Ltracks, color, sub_label) %add custom legend
savename=foo
saveas(gcf, savename);

%% Now for the left side
close all;
[fg_fromtrk]=create_trkstruct(ni_dwi, Ltracks);

%% Plot left tracks
tic
figure(1);
g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'pial_desc-qsiprep.L.surf.gii')); %Will need to do a surface of both sides
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

electrode_tsv=readtable(fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];

%Medtronic 3387 RC+S (total length 57.1mm - extension 46.6mm). R=.75mm
electrodes={''};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.name,electrodes{ii})), .75, 46.6, 0)
%Medtronic 3391 RC+S (total length 57.1mm - extension 32.6mm). R=1.5mm
electrodes={''};
render_dbs_lead(elecmatrix(ismember(electrode_tsv.name,electrodes{ii})), 1.5, 32.6, 0) 
h.FaceAlpha = 0.2;
loc_view(90,0)

addElectrode(elecmatrix(9:16, :), 'b', 0, .2, 9:16); %add blue rendering
custom_legend(Ltracks, color, sub_label) %add custom legend
savename=foo
saveas(gcf, savename);

end

