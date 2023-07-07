%   Jordan Bilderbeek June 26 2023

%   Sanity check to show that the electrode positions are in the same
%   space as the T1 and surfaces. This will 


%% Initialize
clc, clear all, close all

setMyMatlabPaths;
addpath(genpath(pwd)); 
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{5};

electrodepositions = fullfile(bids_path,'sourcedata',['sub-' sub_label], 'positionsBrinkman','electrodes_loc1.mat');
load(electrodepositions);
 
%% CHeck on T1 slice

t1_name = fullfile(bids_path,'sourcedata',['sub-' sub_label], 'positionsBrinkman',['sub-' sub_label '_ses-mri01_T1w_acpc.nii.gz']);
% t1 = readFileNifti(t1_name);
t1 = niftiRead(t1_name);
brighten_T1 = .5; % 1 for nothing, .5 for everything above 50% of maximum is white
t1.data(t1.data>brighten_T1*max(t1.data(:))) = brighten_T1*max(t1.data(:));
t1.sto_xyz = t1.qto_xyz;
t1.sto_ijk = t1.qto_ijk;

AFQ_AddImageTo3dPlot(t1, [10,0,0], [], 0);
ieeg_elAdd(elecmatrix, 'k', 20);

%% Check on Brain surface

g = gifti(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','freesurfer',['sub-' sub_label], 'pial.L.surf.gii'));
figure();
h = ieeg_RenderGifti(g); 
hold on

num_dbs_leads=4;
num_electrodes_per_lead=4;
lead_size=1; 

init=1;
fin=num_electrodes_per_lead;
step=num_electrodes_per_lead;

% We divide the num_dbs_leads by 2 to only iterate through one side (as we
% only have L/R pial surfaces created by freesurfer).

%init and fin ensure that we setp through and grab the right electrode
%positions from the matrix

for ii=1:num_dbs_leads/2
    render_dbs_lead(elecmatrix(init:fin, :), lead_size)
    init=init+step;
    fin=fin+step;
end

h.AmbientStrength=.3;
h.DiffuseStrength=.8;
h.FaceAlpha = 0.2;
light('Position', [270 30 0]);
