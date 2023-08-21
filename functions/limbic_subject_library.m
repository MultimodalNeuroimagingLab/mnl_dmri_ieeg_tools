function [sub_name,bids_path, electrodes, tracks, elpair] = limbic_subject_library(subnum)

%   Jordan Bilderbeek July 26 2023
%
%   Helper to hide paths, subject numbers, and provide electrode numbers
%   and specific tracks for calculations. 
%
%   INPUTS: 
%   a) subnum - positive integer to index my_subject_labels
%
%   OUTPUTS:
%       a) electrodes - cell array of alphanumeric electrode positions found in 
%       sub-[sub_label]_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv
%       b) sub_label - path label
%       c) bids_path - path to top of bids structure
%       d) tracks - cell array of fullfile paths to unzipped .trk files
%       e) elpair - cell array of electrode pairs that lie along the same track
%       (to calculate distance between the contact pairs)


%% Get bids path

[my_subject_labels,bids_path] = dmri_subject_list();

%% Get Subject labels

sub_name=my_subject_labels{subnum};

%% Get electrodes and tracks
switch subnum
    case 6
        dsipath=fullfile(bids_path,'derivatives','qsiprep', ['sub-' sub_name], 'ses-mri01','dwi', 'dsi_studio');
    otherwise
        dsipath=fullfile(bids_path,'derivatives','qsiprep', ['sub-' sub_name], 'ses-compact3T01','dwi', 'dsi_studio');
end

switch subnum
    case 1
        electrodes={'RB1', 'RB2', 'RB3', 'RB4', 'RB5', 'RB6', 'RB7', 'RZ1', 'RZ2', 'RZ3'};
        [~, tracks]=getDSItracks(dsipath, 'no gz');
        elpair={};
    case 2
        electrodes={'LB1', 'LB2', 'LB3', 'LB4', 'LB5', 'LB6', 'LB7' 'LC1', 'LC2', 'LZ1', 'LZ2', 'LZ3', 'LZ4'};
        [tracks, ~]=getDSItracks(dsipath, 'no gz');
        elpair={'LB3', 'LC2', 'Fornix_L.trk'};
    case 3
        electrodes={'LB1', 'LB2', 'LB3', 'LB4', 'LB5', 'LC1', 'LC2', 'LC3', 'LC4', 'LC5', 'LC6', 'LY1', 'LY2', 'LY3', 'LZ1', 'LZ2'};
        [tracks, ~]=getDSItracks(dsipath, 'no gz');
        elpair={'LB3', 'LZ1', 'LZ1.trk'};
    case 4
        electrodes={'RB1', 'RB2', 'RB3', 'RB4', 'RB5', 'RC1', 'RC2', 'RC3', 'RC5', 'RB7', 'RA1', 'RA2', 'RY1', 'RY2', 'RY3', 'RY4', 'RY5'};
        [~, tracks]=getDSItracks(dsipath, 'no gz');
        elpair={'RB3', 'RC1', 'Cingulum_Parahippocampal_R.trk'};
    case 5
        electrodes={'RBC1', 'RBC2', 'RBC3', 'RBC4', 'RBC5', 'RBC6', 'RBC7', 'RY1', 'RY2', 'RY3', 'RQ1', 'RQ2', 'RQ3', 'RZ1', 'RZ2', 'RZ3'};
        [~, tracks]=getDSItracks(dsipath, 'no gz');
        elpair={'RY2', 'RZ1', 'Cingulum_Parolfactory_R.trk'};
    case 6
        electrodes={'RB1', 'RB2', 'RB3', 'RB4', 'RB5', 'RC2', 'RC3', 'RC4', 'RC5', 'RY3', 'RY4', 'RY5', 'RY6', 'RY7', 'RZ1', 'RZ2', 'RZ3'};
        [~, tracks]=getDSItracks(dsipath, 'no gz');
        elpair={};
end







