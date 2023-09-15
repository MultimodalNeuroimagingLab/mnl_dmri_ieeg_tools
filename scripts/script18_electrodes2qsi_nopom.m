
% QSIprep has it's own space, diffusion images with directions etc, not
% something we want to mess with or rotate, so we get electrodes to the
% QSIprep space. We will save a new electrodes.tsv file in the QSIprep folder.
%
% Electrodes, CT, T1, Freesurfer --> qsiprep_T1

%% Dependencies
% vistasoft
% mnl_ieegbasics
% spm

%% Coregister T1 to qsiprep_T1

% We go from T1 to T1, such that it's super reliable. 
% We extract the transformation matrix and apply to all the other files we need. 

% acpcT1 --> qsiprep_T1
[my_subject_labels,bidsDir] = dmri_subject_list();
sub_name=my_subject_labels{7};

% acpcT1 location
acpcT1 = niftiRead(fullfile(bidsDir,'BIDS_subjectsRaw', 'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii']));

% qsiprep_T1
qsiprep_dir = fullfile(bidsDir,'BIDS_subjectsRaw', 'derivatives','qsiprep',['sub-' sub_name]);
qsiprep_T1 = niftiRead(fullfile(qsiprep_dir,'anat',['sub-' sub_name '_desc-preproc_T1w.nii.gz']));

acpc2qsiprepXform = dtiRawAlignToT1(acpcT1,qsiprep_T1,[], [], false, 1); 

%% We have our matrix (acpc2qsiprepXform) we want to apply it to everything and save

% acpc2qsiprepXform = load(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-compact3T01_T1w_acpcAcpcXform.mat']));

% apply matrix to acpc T1 to check
T1_save = acpcT1;
% correct the xform matrices
T1_save.qto_xyz = acpc2qsiprepXform;
T1_save.qto_ijk = inv(acpc2qsiprepXform);
T1_save.sto_xyz = acpc2qsiprepXform;
T1_save.sto_ijk = inv(acpc2qsiprepXform);

%%% optional: save the aligned T1 in qsiprep sapce to check 
T1_saveName = fullfile(qsiprep_dir,['sub-' sub_name '_T1check.nii.gz']);
niftiWrite(T1_save,T1_saveName)

% apply matrix to electrode positions, write electrode positions to check
% load electrode positions from CTMR output

load(fullfile('/Users/M255591/Documents/dMRI_RCpS/sourcedata/', ['sub-' sub_name], 'positionsBrinkman/electrodes_loc1.mat'))
acpc_xyz=elecmatrix;

% apply matrix to cortex renderings
qsiprep_xyz = acpc2qsiprepXform * acpcT1.qto_ijk * [acpc_xyz ones(height(elecmatrix),1)]';

qsiprep_xyz = qsiprep_xyz(1:3,:)';

% write electrodes in qsiprep space in an image to check
disp('select qsiprep folder to write the electrodes in image in qsiprep space to check things')
ieeg_position2reslicedImage(qsiprep_xyz,T1_saveName);

%% Now we need to write a new electrodes.tsv in qsiprep space, WITH LABELS. 

% Change labels to be what you want to call each position. Must be the same
% length as the coordinates (as in each xyz has one label). 
elec_table_qsiprep=table();
elec_table_qsiprep.label=[{'LH4'}, {'LH3'}, {'LH2'}, {'LH1'}, {'LA4'}, {'LA3'}, {'LA2'}, {'LA1'}, {'RA4'}, {'RA3'}, {'RA2'}, {'RA1'}, {'RH4'}, {'RH3'}, {'RH2'}, {'RH1'}]';
%elec_table_qsiprep.x = qsiprep_xyz(:,1);
%elec_table_qsiprep.y = qsiprep_xyz(:,2);
%elec_table_qsiprep.z = qsiprep_xyz(:,3);
elec_table_qsiprep.x = acpc_xyz(:,1);
elec_table_qsiprep.y = acpc_xyz(:,2);
elec_table_qsiprep.z = acpc_xyz(:,3);

figure();
%scatter3(qsiprep_xyz(:,1), qsiprep_xyz(:,2), qsiprep_xyz(:,3))
scatter3(acpc_xyz(:,1), acpc_xyz(:,2), acpc_xyz(:,3))
hold on;
for ii=1:length(elec_table_qsiprep.label)
    text(elec_table_qsiprep.x(ii), elec_table_qsiprep.y(ii), elec_table_qsiprep.z(ii), elec_table_qsiprep.label{ii}, 'VerticalAlignment', 'bottom');
end
pause;

electrodes_tsv_name_qsiprep = fullfile(qsiprep_dir,['sub-' sub_name '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']);
writetable(elec_table_qsiprep, electrodes_tsv_name_qsiprep,'FileType', 'text','Delimiter', '\t');


%% Convert pial, inflated and gray/white from acpc to qsiprep space


% acpcT1
acpcT1 = niftiRead(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpc.nii']));

% qsiprep_T1
qsiprep_dir = fullfile(bidsDir,'BIDS_subjectsRaw', 'derivatives','qsiprep',['sub-' sub_name]);
qsiprep_T1 = niftiRead(fullfile(qsiprep_dir,'anat',['sub-' sub_name '_desc-preproc_T1w.nii.gz']));

% load freesurfer giftis
gL = gifti(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['pial.L.surf.gii']));
gR = gifti(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['pial.R.surf.gii']));
gL_infl = gifti(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['inflated.L.surf.gii']));
gR_infl = gifti(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['inflated.R.surf.gii']));
gL_w = gifti(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['white.L.surf.gii']));
gR_w = gifti(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['white.R.surf.gii']));

% load transformation 
acpc2qsiprepXform = load(fullfile(bidsDir,'derivatives','freesurfer',['sub-' sub_name],['sub-' sub_name '_ses-mri01_T1w_acpcAcpcXform.mat']));

% apply matrix to cortex renderings

% Pial
qsiprep_vert = acpc2qsiprepXform.acpcXform * acpcT1.qto_ijk * [gL.vertices ones(size(gL.vertices,1),1)]';
gL.vertices = qsiprep_vert(1:3,:)';
gL_name = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name],['pial_desc-qsiprep.L.surf.gii']);
save(gL,gL_name,'Base64Binary')

qsiprep_vert = acpc2qsiprepXform.acpcXform * acpcT1.qto_ijk * [gR.vertices ones(size(gR.vertices,1),1)]';
gR.vertices = qsiprep_vert(1:3,:)';
gR_name = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name],['pial_desc-qsiprep.R.surf.gii']);
save(gR,gR_name,'Base64Binary')

% Inflated
qsiprep_vert = acpc2qsiprepXform.acpcXform * acpcT1.qto_ijk * [gL_infl.vertices ones(size(gL_infl.vertices,1),1)]';
gL_infl.vertices = qsiprep_vert(1:3,:)';
gL_infl_name = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name],['inflated_desc-qsiprep.L.surf.gii']);
save(gL_infl,gL_infl_name,'Base64Binary')

qsiprep_vert = acpc2qsiprepXform.acpcXform * acpcT1.qto_ijk * [gR_infl.vertices ones(size(gR_infl.vertices,1),1)]';
gR_infl.vertices = qsiprep_vert(1:3,:)';
gR_infl_name = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name],['inflated_desc-qsiprep.R.surf.gii']);
save(gR_infl,gR_infl_name,'Base64Binary')

% White
qsiprep_vert = acpc2qsiprepXform.acpcXform * acpcT1.qto_ijk * [gL_infl.vertices ones(size(gL_infl.vertices,1),1)]';
gL_infl.vertices = qsiprep_vert(1:3,:)';
gL_infl_name = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name],['white_desc-qsiprep.L.surf.gii']);
save(gL_infl,gL_infl_name,'Base64Binary')

qsiprep_vert = acpc2qsiprepXform.acpcXform * acpcT1.qto_ijk * [gR_infl.vertices ones(size(gR_infl.vertices,1),1)]';
gR_infl.vertices = qsiprep_vert(1:3,:)';
gR_infl_name = fullfile(bidsDir,'derivatives','qsiprep',['sub-' sub_name],['white_desc-qsiprep.R.surf.gii']);
save(gR_infl,gR_infl_name,'Base64Binary')
