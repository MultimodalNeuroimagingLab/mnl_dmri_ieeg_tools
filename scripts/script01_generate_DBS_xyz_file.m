
%   Jordan Bilderbeek June 15 2023

%   Script to generate reco struct that can be implemented in LeadDBS for
%   the x,y,z positions. 

%% Initialize

setMyMatlabPaths;
addpath(genpath(pwd)); 
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{1};

%% Start determining positions and rows
electrodes_tsv = fullfile(bids_path,['sub-' sub_label],['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']);
loc_info = readtable(electrodes_tsv,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});

row=retrieve_row_key_letter('pall', loc_info); 
elecmatrix = [loc_info.x loc_info.y loc_info.z];

lead1={'LA1', 'LA11'};
lead2={'LC1', 'LC11'};

%% Generate Reco struct

reco=struct();
reco.props(1).elmodel = ''; %Electrode type (ex. 'Medtronic 3389')
reco.props(2).elmodel = ''; %Electrode type (ex. 'Medtronic 3389')
reco.props(1).manually_corrected = 1;
reco.props(2).manually_corrected = 1;
reco.mni.markers(1).head = elecmatrix(ismember(loc_info.name, lead1(1)), :); %Head of lead 1
reco.mni.markers(1).tail = elecmatrix(ismember(loc_info.name, lead1(2)), :); %Tail of lead 1
reco.mni.markers(2).head = elecmatrix(ismember(loc_info.name, lead2(2)), :); %Head of lead 2
reco.mni.markers(2).tail = elecmatrix(ismember(loc_info.name, lead2(2)), :); % Tail of lead 2
   
% reco.mni.markers(1).head = [10 10 10]; %Head of the electrode
% reco.mni.markers(1).tail = [10 10 0]; %Tail of the electrode
% reco.mni.markers(2).head = [20 20 20];
% reco.mni.markers(2).tail = [20 20 0];
save('ea_reconstruction.mat', 'reco');
    