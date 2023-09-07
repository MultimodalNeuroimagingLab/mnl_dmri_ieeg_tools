
%   Jordan Bilderbeek August 22 2023
%
%   dsi_parameter_eval has the purpose of comparing different DSI studio
%   parameters - creates a FIB file for each subject then performs tracking
%   on selected tracks based on parameter IDs. 
%
%   Requirements: This script requires a derivatives folder titled dsi
%   testing for all subjects, with the bval, bvec, and ni_dwi file placed
%   inside.
%

%% dsi_parameter_eval
setMyMatlabPaths
[my_subject_labels,bids_path] = dmri_subject_list();

%list of hemisphere and tracks for subjects
hemi_allsub={'R', 'L', 'L', 'R', 'R', 'R'};
tracks_allsub={'Fornix_', 'Cingulum_Parolfactory_', 'Cingulum_Parahippocampal_', 'Cingulum_Parahippocampal_Parietal_', 'Cingulum_Frontal_Parietal_'};

%preallocate 
p_mat=zeros(length(my_subject_labels), length(tracks_allsub));
h_mat=zeros(length(my_subject_labels), length(tracks_allsub));

for subjects=1:length(my_subject_labels)
    
    %Get path to dsitesting folder
    sub=my_subject_labels{subjects};
    path=fullfile(bids_path, 'derivatives', 'dsitesting', ['sub-' sub]); 
    
    %Get NIFTI path and create SRC
    nifti_path=dir(fullfile(path , '*.nii.gz'));
    nifti_path=fullfile(path, nifti_path(1).name);
    
    try
        SRC_path=dir(fullfile(path , '*.src.gz'));
        SRC_path=fullfile(path, SRC_path(1).name);
    catch
        SRC_call=['export DSI_HOME=/Applications/dsi_studio.app/Contents/MacOS && cd $DSI_HOME && ./dsi_studio --action=src --source=' nifti_path];

        disp('Running DSI studio in Matlab instance')
        disp('-------------------------------')
        disp(SRC_call)
        system(SRC_call);
    end
    
    SRC_path=dir(fullfile(path , '*.src.gz'));
    SRC_path=fullfile(path, SRC_path(1).name);
    
    try
        FIB_path=dir(fullfile(path , '*.fib.gz'));
        FIB_path=fullfile(path, FIB_path(1).name);
    catch
        FIB_call=['export DSI_HOME=/Applications/dsi_studio.app/Contents/MacOS && cd $DSI_HOME && ./dsi_studio --action=rec --source=' SRC_path ' --method=4 --param0=1.25 --align_acpc=0 --check_btable=1'];

        disp('Running DSI studio in Matlab instance')
        disp('-------------------------------')
        disp(FIB_call)
        system(FIB_call);
    end
    
    %Get FIB path and auto track
    FIB_path=dir(fullfile(path , '*.fib.gz'));
    FIB_path=fullfile(path, FIB_path(1).name);
    
    %Get the specific hemisphere, and corresponding track names for each
    %subject
    hemi=hemi_allsub{subjects};
    tracks_onesub=strcat(tracks_allsub, hemi);
    ni_dwi=niftiRead(nifti_path);
    
    %Load up the tracks
    for tracks=1:length(tracks_allsub)
        
        target_roi=tracks_onesub{tracks};
        
        %DSI autotrack random params
        random_id='c9A99193Fb803FdbA041b96438813cb01cbaCDCC4C3Ec';
        random_trk_call=['export DSI_HOME=/Applications/dsi_studio.app/Contents/MacOS && cd $DSI_HOME && ./dsi_studio --action=trk --source=' FIB_path ' --parameter_id=' random_id ' --track_id=' target_roi ' --output=' path '/' target_roi '_rndm.trk']; 
        
        disp('Running DSI studio in Matlab instance')
        disp('-------------------------------')
        disp(random_trk_call)
        system(random_trk_call);
       
        random_track=fullfile(path, [target_roi '_rndm.trk']);
        
        %DSI autotrack non-random params
        non_random_id='CDCCCC3D9A99193FD7B35D3Fb803FcbA041b96438813cb01cbaCDCC4C3Ec';
        non_random_trk_call=['export DSI_HOME=/Applications/dsi_studio.app/Contents/MacOS && cd $DSI_HOME && ./dsi_studio --action=trk --source=' FIB_path ' --parameter_id=' non_random_id ' --track_id=' target_roi ' --output=' path '/' target_roi '_non_rndm.trk']; 
        
        disp('Running DSI studio in Matlab instance')
        disp('-------------------------------')
        disp(non_random_trk_call)
        system(non_random_trk_call);        
        
        non_random_track=fullfile(path, [target_roi '_non_rndm.trk']);
        
        % Create track structures
        random_trkstruct=create_trkstruct(ni_dwi, {random_track});
        non_random_trkstruct=create_trkstruct(ni_dwi, {non_random_track});
        
        total_distance_random=zeros(length(random_trkstruct.fibers), 1);
        for ii=1:length(random_trkstruct.fibers)
            total_distance_random(ii) = trk_distance(random_trkstruct.fibers{ii}(1, :), random_trkstruct.fibers{ii}(2, :), random_trkstruct.fibers{ii}(3, :), []);
        end
        
        total_distance_non_random=zeros(length(random_trkstruct.fibers), 1);
        for ii=1:length(random_trkstruct.fibers)
            total_distance_non_random(ii) = trk_distance(non_random_trkstruct.fibers{ii}(1, :), non_random_trkstruct.fibers{ii}(1, :), non_random_trkstruct.fibers{ii}(1, :), []);   
        end
        
        %KS test
        std_random=std(total_distance_random);
        std_non_random=std(total_distance_non_random);

        [h,p]=kstest2(total_distance_random, total_distance_non_random);
        %disp(['Test result: ' num2str(h)]);
        %disp(['p-value: ' num2str(p)]);
        
        %Our assumption is that if the KS test is true, it is because the 
        % non_random is less variable. But if it is, then assign to a
        % negative h value (negative significance). 
        
        if std_random < std_non_random 
            h=h*-1;
        end
            
        %Save output
        p_mat(subjects, tracks)=p;
        h_mat(subjects, tracks)=h;
        
    end
end

imagesc(p_mat);

