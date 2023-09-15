
%   Jordan Bilderbeek August 22, 2023
%
%   script to plot atlas regions on a population average template

%% Dependencies
%
%   clone the dependencies into a local github repo and addpath:
%
%   vistasoft - https://github.com/vistalab/vistasoft
%   mnl_ieegBasics - https://github.com/MultimodalNeuroimagingLab/mnl_ieegBasics
%   mnl_dmri_ieeg_tools - https://github.com/JordanBld/mnl_dmri_ieeg_tools
%   spm12 - https://github.com/spm/spm12
%   Paper_Hermes_2010_JNeuroMeth - https://github.com/dorahermes/Paper_Hermes_2010_JNeuroMeth
%   AFQ - https://github.com/yeatmanlab/AFQ
%
%   download the following dependencies to your machine:
%
%   freesurfer - https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall


%% STEP 1: Run FREESURFER RECON-ALL 

%Freesurfer version (may need to change i.e 7.2)
freesurfer_vers='export FREESURFER_HOME=/Applications/freesurfer/7.4.1';

path= '~/Desktop/test';
average_template='template.nii';

%Create output directory
outputdir = fullfile(path, 'freesurfer');
outputdir=['export SUBJECTS_DIR=' outputdir];

%Set up environment for FreeSurfer/FS-FAST (and FSL)
env="source /Applications/freesurfer/7.4.1/SetUpFreeSurfer.sh";

%Recon call; may need to adjust based on ses
recon=['recon-all -s sub-01 -i ' fullfile(path, average_template) ' -cw256 -all -notal-check'];

syscall=strjoin([freesurfer_vers '&&' env '&&' outputdir '&&' recon]);
disp('Running system call in MATLAB instance')
disp(syscall)
system(syscall)

%% STEP 2: Get GIFTIs - in original T1/atlas space

ieeg_FSsurf2T1space(fullfile(%path to freesurfer subject folder),[]);

%% STEP 3a: Render the R pial surfaces

figure();
% Surface for R side
g = gifti(fullfile(%path to gifti generated (pial surface) file)); 
h=ieeg_RenderGifti(g); 
h.FaceAlpha=.3;

%% STEP 4a: Render the ROIs

col=jet(5);
ROI=niftiRead(fullfile(%path to atlas.nii file));
if isempty(ROI.data)
    ROI=niftiReadMatlab(fullfile(%path to atlas.nii file));
end

seg=%segmentation value
cntrl_roi1=renderROI(ROI, col(1, :), seg);
cntrl_roi1.FaceAlpha=.5;

%if you would like to loop through the areas we can:
col=jet(length(numareas)); %create a colormap based on the number of areas
listseg=[1, 2, 3, foo]; %array list to index through with your segmentation values
listalpha=[.1, .2, .3, foo]; %array list to index through with the alpha (can order by significance)
for areas=1:length(numareas)
    h=renderROI(ROI, col(areas, :), listseg(areas));
    h.FaceAlpha=listalpha(areas);
end

%if the ROIs are not in the right space, let me know and I can send you
%some code to fix it - Jordan

