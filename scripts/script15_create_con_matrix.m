
%   Jordan Bilderbeek August 8 2023
%
%   create_con_matrix will create a connectivity matrix for the given
%   limbic subject. we create nifti files with 2mm spheres around the
%   centroid electrode contact and perform seed tracking for each
%   individual region. we then create a connectivity matrix via the HCP842
%   tractography atlas (80 tracks - 40L/R). 
%
%   the connectivity matrices are concatenated and saved as the 
%   connectivitytotal variable (80x80x10)
%
%   the connectivity matrices matrices are summed together and saved as the
%   connectivitysum variable (80x80)
%
%   we can plot and perform dimensionality reduction if needed
%
%   For the function to run, we require a specific setup. The T1w that is
%   being used in the ieeg_positions2reslicedImage needs to first be
%   resliced to the dimensions of the dwi tracking file. Do this in SPM.
%   Then put all of the images in
%   derivatives/qsiprep/sub#/ses-compact3T/dwi/dsi_autotrack - this creates
%   a seperate folder so that we are not bombarding another location with
%   multiple electrodes2image iterations. We also assume that we already
%   have the fib file - these must be created via dsi studio manually (run
%   gqi at 1mm, check b, no preproc/acpc align)
%
%   if we are rerunning, you must clear the electrodes2image files from the
%   directory
%

%% create_con_matrix
clear all;
close all;
subnum=6;
[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);

%read electrode tsv
electrode_tsv=readtable(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_space-T1w_desc-qsiprep_electrodes.tsv']), 'FileType', 'text', 'Delimiter', '\t');
elecmatrix = [electrode_tsv.x electrode_tsv.y electrode_tsv.z];  

%fullpath to the fib file
fib=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-compact3T01', 'dwi','dsi_autotrack', ['sub-' sub_label '_ses-compact3T01_acq-diadem_space-T1w_desc-preproc_dwi.nii.gz.src.gz.gqi.1.fib.gz']);
fib=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-mri01', 'dwi','dsi_autotrack', ['sub-' sub_label '_ses-mri01_acq-axdti_space-T1w_desc-preproc_dwi.nii.gz.src.gz.gqi.1.fib.gz']);

connectivitysum=zeros(80,80); %80x80 connectivity matrix
for ii=1:length(electrodes)
    
    %Create nifti file with 2mm sphere around electrode position
    ieeg_position2reslicedImage(elecmatrix(ismember(electrode_tsv.name,electrodes{ii}),:),fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-mri01', 'dwi', 'dsi_autotrack', ['rsub-' sub_label '_desc-preproc_T1w.nii']), fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-mri01', 'dwi', 'dsi_autotrack'));
    
    %Load the created nifti file
    ni=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-compact3T01', 'dwi', 'dsi_autotrack', ['Electrodes2Image_' num2str(ii) '.nii']);
    ni=fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-mri01', 'dwi', 'dsi_autotrack', ['Electrodes2Image_' num2str(ii) '.nii']);

    %Write the whole system call; then execute
    syscall=['export DSI_HOME=/Applications/dsi_studio.app/Contents/MacOS && cd $DSI_HOME && ./dsi_studio --action=trk --seed=' ni  ' --source=' fib ' --parameter_id=c9A99193Fb803FdbA041b96438813cb01cbaCDCC4C3Ec --output=no_file --connectivity=HCP842_tractography --connectivity_value=count --connectivity_type=pass' ];
    
    disp('Running DSI studio in Matlab instance')
    disp('-------------------------------')
    disp(syscall)
    
    system(syscall);
   
    %load connectivitymatrix, these are continually re-written
    connectivitymatrix=load(fullfile(bids_path, 'derivatives', 'qsiprep', ['sub-' sub_label], 'ses-mri01', 'dwi', 'dsi_autotrack', ['sub-' sub_label '_ses-mri01_acq-axdti_space-T1w_desc-preproc_dwi.nii.gz.src.gz.gqi.1.fib.gz.tt.gz.HCP842_tractography.count.pass.connectivity.mat']));
    connectivitysum=connectivitysum + connectivitymatrix.connectivity;
    if ii==2
        connectivitytotal=cat(3, connectivitysum, connectivitymatrix.connectivity); %first pass connectivity sum is zero so we can add it on the second pass
    elseif ii>2
        connectivitytotal=cat(3, connectivitytotal, connectivitymatrix.connectivity); %after ii=2 we have connectivitytotal so we can concatenate freely
    end
end

labels = textscan(char(connectivitymatrix.name),'%s');
labels=labels{:}(1:80); %assume we have 80x80
labels=regexprep(labels, '_', ' ');

connectmat.connectivitytotal=connectivitytotal;
connectmat.connectivitysum=connectivitysum;
connectmat.labels=labels;
connectmat.subj=['sub-' sub_label];
connectmat.electrode=electrodes;
savepath=fullfile(bids_path, 'derivatives','stats',['sub-' sub_label], ['sub-' sub_label '_connectivitymat.mat']);
save(savepath, 'connectmat');

%% optional -- plotting for the surface

% figure(1);
% surf(connectivitysum, 'EdgeColor', 'none', 'FaceColor', 'interp');
% set(gca,'XTick', 1:80,'YTick', 1:80, 'XTickLabel',labels', 'YTickLabel', labels);
% zlabel('Number of tracks passing through both regions')
% title('Sum of all electrodes - connectivity matrix (units=count#)')
% colormap jet
% shading interp
% lighting phong
% camlight left
% material shiny
% 
% 
% %% optional -- create 1st pc reconstruction
% reshape_mat=reshape(connectivity, [], size(connectivity, 1));
% [coeff, score, ~, ~, explained]=pca(reshape_mat); %perform pca
% 
% first_pc_recon=score(:, 1) * coeff(:, 1)';
% first_pc_recon=reshape(first_pc_recon, size(connectivitytotal, 1), size(connectivitytotal, 2));
% 
% figure(2)
% subplot(1, 2, 1)
% imagesc(first_pc_recon);
% set(gca,'XTick', 1:80,'YTick', 1:80, 'XTickLabel',labels', 'YTickLabel', labels);
% colorbar
% title('1st Principal Component Reconstruction');
% 
% subplot(1, 2, 2)
% scatter3(score(:, 1), score(:, 2), score(:, 3));
% xlabel('PCA1 (au)');
% ylabel('PCA2 (au)');
% zlabel('PCA3 (au)');


