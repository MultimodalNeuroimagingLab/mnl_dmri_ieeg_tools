
%   Jordan Bilderbeek August 9 2023
%
%   Electrode contact nifti files were manually created for all limbic
%   electrodes using ieeg_position2reslicedImage; they were then inserted
%   into DSI studio where we performed seed tracking. script15 will do this
%   tracking automatically via the CLI, however, the connectivity matrices
%   via the CLI do not allow for ROI functionality (only atlases) - unless
%   you manually add your ROIs to the atlas. 
%
%   Each connectivity matrix was saved for the contact point (ie
%   RB5=RB5.mat); the tracks were saved in the dsi_autotrack folder if we
%   want to visualize them as well. 
%
%   Based on the subject we want to load each connectivity matrix and parse
%   it into the correct hemi (remove non-hemi entries) and only select the
%   row that corresponds to electrode-track as we are interested in the
%   streamlines that pass through both the electrode seed start location
%   and the track
%
%   We can then concatenate the rows into a seperate matrix that is
%   electrode#s x tracks

%% parse_dsi_matrix
clear all;
close all;
setMyMatlabPaths;
addpath(genpath(pwd));
subnum=2;

[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);
hemi=electrodes{1}(1); %take first char from first electrode, either R/L

for ii=1:length(electrodes)
    electrodename=electrodes{ii};
    matrix=load(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-compact3T01', 'dwi', 'dsi_autotrack', [electrodename '.mat'])); 
    labels = textscan(char(matrix.name),'%s'); %take labels from connectivity matrix
    labels=labels{:}(1:end-1);
    
    electrode_ind=find(strcmp(labels, electrodename));
    hemi_ind=cellfun(@(str) endsWith(str, hemi), labels); %search through the labels to find the indexes within our hemisphere)
    
    connectmatrix(ii, :)=matrix.connectivity(electrode_ind, hemi_ind); %find the row with the electrode, take the columns with hemi_ind
    labels=labels(hemi_ind);
    
end

sz=size(connectmatrix);

labels=regexprep(labels, '_', ' ');
figure(1)
imagesc(connectmatrix')
set(gca,'YTick', 1:sz(2), 'YTickLabel', labels, 'XTick', 1:sz(1), 'XTickLabel', electrodes);
colorbar
colormap jet
xlabel('Electrode Contact Seeds')
ylabel('Tracks')
title(['sub-' sub_label ' Seed Tracking via Electrode Contacts'])

padd=zeros(min(sz), min(sz));
totalconnectmatrix=[padd, connectmatrix]; %padd the matrix such that we have no connections from electrode to electrode
colors=[jet(min(sz)); repmat([0 0 0], max(sz), 1)]; %get a jet colormap for the contacts, the rest are 0 0 0;

figure(2)
circularGraph(totalconnectmatrix, 'Label', [electrodes'; labels], 'Color', colors);
title(['sub-' sub_label ' Circular representation of node connections via seed tracking'])
%saveallfig
