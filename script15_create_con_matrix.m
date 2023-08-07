
subnum=1;
[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);

electrode_tsv=readtable(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];  

fib=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label]);

for ii=1:length(electrodes)
    ieeg_position2reslicedImage(elecmatrix(ismember(electrode_tsv.name,electrodes{ii}),:),fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label 'T1check.nii.gz']), fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label]))
    ni=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['Electrodes2Image_' num2str(ii) '.nii']');
    syscall=['dsi_studio --action=trk --seed=' ni '--source=' fib '--parameter_id=string --output=no_file --connectivity=HCP842-tractography:Cingulum_R,HCP842-tractography:Cingulum_L, HCP842-tractography:Fornix_R, HCP842-tractography:Fornix_L,' ni '--connectivity_value=count --connectivity_type=pass']

end


