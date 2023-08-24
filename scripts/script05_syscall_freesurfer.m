% Jordan Bilderbeek June 21, 2023

% The purpose of the script is to create a system call to the terminal to run freesurfer reconstructions. 
% The general format of the call is as follows:

% export SUBJECTS_DIR=/Path/where/your/local/derivatives/freesurfer/
% recon-all -s YourSubjectName -i /path/to/your/T1w_acpc.nii

clc, clear all;

%% Build the call

%Freesurfer version (may need to change i.e 7.2)
freesurfer_vers='export FREESURFER_HOME=/Applications/freesurfer/7.4.1';

%Where sub_label is MSEL#####, bids path is path to the wd
[my_subject_labels, bids_path]=dmri_subject_list();

%Change my_subject_labels{#} to those preset in function. 
sub_label=my_subject_labels{5};

%Create output directory
outputdir = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label]);
outputdir=['export SUBJECTS_DIR=' outputdir];

%Set up environment for FreeSurfer/FS-FAST (and FSL)
env="source /Applications/freesurfer/7.4.1/SetUpFreeSurfer.sh";

%Recon call; may need to adjust based on ses (i.e mri01 vs compact3T01)
recon=['recon-all -s ' sub_label ' -i ' fullfile(bids_path, 'sourcedata', ['sub-' sub_label], 'positionsBrinkman', ['sub-' sub_label '_ses-mri01_T1w_acpc.nii -cw256 -all'])];
recon=['recon-all -s ' sub_label ' -i ' fullfile(bids_path, 'sourcedata', ['sub-' sub_label], 'positionsBrinkman', ['sub-' sub_label '_ses-compact3T01_T1w_acpc.nii -cw256 -all'])];


syscall=strjoin([freesurfer_vers '&&' env '&&' outputdir '&&' recon]);
disp('Running system call in MATLAB instance')
disp(syscall)

stat=system(syscall);
if stat ~=0
    disp('Problem with system call')
end
