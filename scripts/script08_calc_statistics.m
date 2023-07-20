%   Jordan Bilderbeek July 19 2023
%
%   Script to calculate statistics (distance and angles) for one subject.
%   Change subnum to move through the subject labels. 
%   We save all the statistics in the el struct. 
%
%   The structure is organized as a 1x16 with fields name and trackstats.
%   Name is the electrode contact # and either R/L. If we index into the
%   el.trackstats, it is a 1xN structure array with name of the fibers,
%   fibers (points), distance, and angle. 
%
%   To pull out a the angle between a specific electrode and fiber, index
%   via el(contact#).trackstats(track#).angle.
%
%   NaN's are present in the el.trackstats.angle when there were less than
%   two points under X distance (set in the strm_angle function call) as we
%   cannot fit the PC axis and calculate the subsequent angle. 


%% calc statistics - distance and angle (RIGHT SIDE - el 9:16)
% this assumes we have the right side fg_fromtrk struct and are using
% elecmatrix(9:16, :)
subnum=1;
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label]);
[Ltracks, Rtracks]=getDSItracks(dsipath);
[Ltracks, Rtracks]=gz_unzip(Ltracks, Rtracks);

%Load DWI file:
switch subnum
    case 2
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-compact3T01','dwi',['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    case 4
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz']);
    otherwise
        dwi_file = fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'qsiprep', ['sub-' sub_label],'ses-mri01','dwi',['sub-' sub_label '_ses-mri01_rec-none_run-01_space-T1w_desc-preproc_dwi.nii.gz']);
end

ni_dwi = niftiRead(dwi_file);
fg_fromtrk = [];

for ss = 1:length(Rtracks)
    trk_file = Rtracks{ss};
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file);
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
        end

        trk_name=regexp(trk_file, '/', 'split');
        fg_fromtrk(ss).name = regexprep(trk_name{end}, '_R.trk', '');
        fg_fromtrk(ss).fibers = cell(length(tracks),1);
        for kk = 1:length(tracks)
            this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
            fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:);
            clear this_strm
        end
        clear header tracks
    else
        warningMessage = sprintf('Warning: Track file does not exist:\n%s', trk_file);
    return;
    end
end

electrodepositions = fullfile(bids_path,'BIDS_subjectsRaw','derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_space-T1w_desc-qsiprep_electrodes.tsv']);
elecmatrix=readtable(electrodepositions, 'FileType', 'text', 'Delimiter', '\t');
elecmatrix=table2array(elecmatrix);

for ii=1:length(elecmatrix)
    el(ii+8).name=['R-Electrode ' num2str(ii+8)];
    fg_fromtrk=euclidean_distance(fg_fromtrk, elecmatrix(ii+8, :));
    el(ii+8).trackstats = strm_angle(fg_fromtrk,elecmatrix(ii+8, :), 2);
end

%% calc statistics - distance and angle (LEFT SIDE - el 1:8)
disp('Now calculating left side')

fg_fromtrk = [];

for ss = 1:length(Ltracks)
    trk_file = Ltracks{ss};
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file);
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
        end

        trk_name=regexp(trk_file, '/', 'split');
        fg_fromtrk(ss).name = regexprep(trk_name{end}, '_L.trk', '');
        fg_fromtrk(ss).fibers = cell(length(tracks),1);
        for kk = 1:length(tracks)
            this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
            fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:);
            clear this_strm
        end
        clear header tracks
    else
        warningMessage = sprintf('Warning: Track file does not exist:\n%s', trk_file);
    return;
    end
end

for ii=1:length(elecmatrix)
    el(ii).name=['L-Electrode ' num2str(ii)];
    fg_fromtrk=euclidean_distance(fg_fromtrk, elecmatrix(ii, :));
    el(ii).trackstats = strm_angle(fg_fromtrk,elecmatrix(ii, :), 2);
end

%% save statistics
dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
save(dsipath, 'el');
