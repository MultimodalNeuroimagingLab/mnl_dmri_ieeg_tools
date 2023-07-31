subnum=1;
[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);

% Where we are loading struct from
statspath=fullfile(bids_path, 'derivatives','stats',['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_dist_angle_stats.mat']);
load(statspath);


for kk=1:length(tracks)

    clear g;
    close all;
    angle=[];

    for ii=1:length(electrodes)
        for jj=1:length(limbic_dist_stats(ii).trackstats(kk).angle)
            angle=[angle; limbic_dist_stats(ii).trackstats(kk).angle{jj}];
        end
        ind=find(angle<4);
        pct=100*length(ind)/length(angle);
        %colmap=zeros(length(angle), 1) + 1;
        %colmap(ind)=2;
        
        trkname=limbic_dist_stats(ii).trackstats(kk).name;
        g(ceil((ii)/3),mod(ii-1, 3) + 1)=gramm('x', angle, 'color', colmap);
        g(ceil((ii)/3),mod(ii-1, 3) + 1).set_names('color','Under/Over','y','Streamline Frequency','x','Nearest Distance (mm)');
        g(ceil((ii)/3),mod(ii-1, 3) + 1).stat_bin('geom','overlaid_bar');
        g(ceil((ii)/3),mod(ii-1, 3) + 1).set_title(['Electrode Contact: ' electrodes{ii} '; Percent under 4mm: ' num2str(pct)]);
        
        angle=[];
    end

    g.set_title(['Minimum distances to ' trkname ' sub-' sub_label]);
    figure('Position',[100 100 800 600]);
    g.geom_vline('xintercept',4);
    g.draw();
    outname=['sub-' sub_label '_trkdist_hist_' trkname];
    g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');
    
end