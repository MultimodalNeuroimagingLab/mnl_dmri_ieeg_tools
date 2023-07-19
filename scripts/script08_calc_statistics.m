%   Jordan Bilderbeek July 19 2023

%   Performs a function call to euclidean distance. We have to iterate over
%   the electrode positions and can save them out in a seperate structure.
%   The rendering needs to be performed before such that we have the
%   elecmatrix and fg_fromtrk structure. 


%% calc statistics - distance and angle (RIGHT SIDE - el 9:16)
% this assumes we have the right side fg_fromtrk struct and are using
% elecmatrix(9:16, :)

elecmatrix=elecmatrix(9:16, :);
for ii=1:length(elecmatrix)
    elname=ii+8;
    el(elname).name=['R-Electrode ' num2str(elname)];
    el(elname).trackstats=euclidean_distance(fg_fromtrk, elecmatrix(ii, :), 'angle');
end

%% calc statistics - distance and angle (LEFT SIDE - el 1:8)

elecmatrix=elecmatrix(1:8, :);
for ii=1:length(elecmatrix)
    el(ii).name=['L-Electrode ' num2str(ii)];
    el(ii).trackstats=euclidean_distance(fg_fromtrk, elecmatrix(ii, :), 'angle');
end

%% save statistics

[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{3};
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
save(dsipath, 'el');
