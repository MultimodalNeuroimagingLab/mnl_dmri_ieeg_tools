[my_subject_labels,bids_path] = dmri_subject_list();
thresh=[17, 18, 53, 54];

%% Write MRIcroGL script

for ii=1:length(my_subject_labels)

    % Lets first segment the data. We'll make the hippocampus and amygdala
    % the same color bilaterally. 

    sub_label=my_subject_labels{ii};
    img=niftiRead(fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr.nii.gz'));
    img.data=double(img.data);
    img.data(~ismember(img.data, thresh))=nan;
    img.data(ismember(img.data, thresh(1)))=1;
    img.data(ismember(img.data, thresh(2)))=2;
    img.data(ismember(img.data, thresh(3)))=1;
    img.data(ismember(img.data, thresh(4)))=2;
    niftiWrite(img, fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_seg.nii.gz'));

    %% Now lets create a script for MRIcroGL

    % Establish the setup
    setup=['import gl' newline 'gl.resetdefaults()'];

    % Add T1, and segmentation
    t1path=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], ['sub-' sub_label '_ses-mri01_T1w_acpc.nii']);
    t1=['gl.loadimage("' t1path '")'];
    segpath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_lr_seg.nii.gz');
    segs=['gl.overlayload("' segpath '")' newline 'gl.colorname(1, "Viridis")' newline 'gl.minmax(1,0,2)' newline 'gl.opacity(1, 100)']; %where (1, ..) denotes the first overlay

    % Lets now write the electrode positions as nifti files so that we can
    % overlay
    load(fullfile(bids_path, 'sourcedata', ['sub-' sub_label], 'positionsBrinkman', 'electrodes_loc1.mat')); %load electrodes
    ieeg_position2reslicedImage(elecmatrix, t1path, fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label]));
    elec_overlay=fullfile(bids_path, 'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], 'Electrodes2Image_1.nii');
    elec_call=['gl.overlayload("' elec_overlay '")' newline 'gl.colorname(2, "4hot")' newline 'gl.minmax(2, 0, 1)' newline 'gl.opacity(2, 100)'];

    % Mess with the colors
    colorbar=['gl.colorbarposition(2)' newline 'gl.colorbarsize(0.05)'];

    % Lets use the electrode positions to determine where we want out
    % montage slices to be:
    slices(1:4)=elecmatrix(1:4, 2);
    slices(5:8)=elecmatrix(13:16, 2);
    slices=round(slices);
    mosaic=['gl.mosaic("C L+ H 0 ' num2str(slices(1)) ' ' num2str(slices(2)) ' ' num2str(slices(3)) ' ' num2str(slices(4)) ' ' num2str(slices(5)) '; ' num2str(slices(6)) ' ' num2str(slices(7)) ' ' num2str(slices(8)) ' S X R 0")'];
    outpath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives', 'freesurfer', ['sub-' sub_label], sub_label, 'mri', 'hippocampus_amygdala_mosaic.png');

    savepic=['gl.savebmp("' outpath '")'];

    MRIcroGL_call=[setup newline t1 newline segs newline elec_call newline colorbar newline mosaic newline savepic];
    clipboard('copy', MRIcroGL_call);
    pause

end
