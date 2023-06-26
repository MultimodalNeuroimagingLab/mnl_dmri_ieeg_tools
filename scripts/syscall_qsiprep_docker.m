% Jordan Bilderbeek June 21, 2023

% The purpose of the script is to create a system call to the terminal to run qsiprep. 
% The general format of the call is as follows:

%  docker run qsiprep [-h] [--version] [--skip_bids_validation]
%                [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
%                [--acquisition_type ACQUISITION_TYPE]
%                [--bids-database-dir BIDS_DATABASE_DIR]
%                [--bids-filter-file FILE] [--interactive-reports-only]
%                [--recon-only] [--recon-spec RECON_SPEC]
%                [--recon-input RECON_INPUT]
%                [--freesurfer-input FREESURFER_INPUT] [--skip-odf-reports]
%                [--nthreads NTHREADS] [--omp-nthreads OMP_NTHREADS]
%                [--mem_mb MEM_MB] [--low-mem] [--use-plugin USE_PLUGIN]
%                [--anat-only] [--dwi-only] [--infant] [--boilerplate] [-v]
%                [--ignore {fieldmaps} [{fieldmaps} ...]] [--longitudinal]
%                [--b0-threshold B0_THRESHOLD]
%                [--dwi_denoise_window DWI_DENOISE_WINDOW]
%                [--denoise-method {dwidenoise,patch2self,none}]
%                [--unringing-method {none,mrdegibbs}] [--dwi-no-biascorr]
%                [--no-b0-harmonization] [--denoise-after-combining]
%                [--separate_all_dwis]
%                [--distortion-group-merge {concat,average,none}]
%                [--write-local-bvecs]
%                [--output-space {T1w,template} [{T1w,template} ...]]
%                [--template {MNI152NLin2009cAsym}] --output-resolution
%                OUTPUT_RESOLUTION [--b0-to-t1w-transform {Rigid,Affine}]
%                [--intramodal-template-iters INTRAMODAL_TEMPLATE_ITERS]
%                [--intramodal-template-transform {Rigid,Affine,BSplineSyN,SyN}]
%                [--b0-motion-corr-to {iterative,first}]
%                [--hmc-transform {Affine,Rigid}]
%                [--hmc_model {none,3dSHORE,eddy}] [--eddy-config EDDY_CONFIG]
%                [--shoreline_iters SHORELINE_ITERS]
%                [--impute-slice-threshold IMPUTE_SLICE_THRESHOLD]
%                [--skull-strip-template {OASIS,NKI}] [--skull-strip-fixed-seed]
%                [--skip-t1-based-spatial-normalization]
%                [--fs-license-file PATH] [--do-reconall]
%                [--prefer_dedicated_fmaps] [--fmap-bspline] [--fmap-no-demean]
%                [--use-syn-sdc] [--force-syn] [-w WORK_DIR]
%                [--resource-monitor] [--reports-only] [--run-uuid RUN_UUID]
%                [--write-graph] [--stop-on-first-crash][--notrack] [--sloppy]
%                bids_dir output_dir {participant}

%% Create call

%Where sub_label is MSEL#####, bids path is path to the wd
[my_subject_labels, bids_path]=dmri_subject_list();

%Change my_subject_labels{#} to those preset in function. 
sub_label=my_subject_labels{3};

%Path of the bids directory
bids_dir=bids_path;

%Path for output file
output_dir=[bids_path '/derivatives'];

%Freesurfer license
fs_license='/Users/M255591/license.txt';

%Output resolution
output_resolution=1.25; %mm

%Create call
call=[ 'docker run pennbbl/qsiprep:0.16.0RC3 ' bids_dir ' ' output_dir ' participant --participant_label ' sub_label ' --fs-license-file ' fs_license ' --output-resolution ' num2str(output_resolution) ' --skip_bids_validation --write-graph -vv' ];
%clipboard('copy', call);

stat=system(call);
if stat~=0
    disp('Error running qsiprep')
end







