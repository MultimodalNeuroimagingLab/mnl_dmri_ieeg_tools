
%   Jordan Bilderbeek July 26 2023
%
%   A script to evaluate the values that we calculate in
%   script08_calc_statistics. Currently supports plotting using the gramm
%   toolbox (ggplot like plotting). 
%

%%
clear all; close all;

subnum=6;
[sub_label,bids_path, electrodes, tracks] = limbic_subject_library(subnum);

% Where we are loading struct from
statspath=fullfile(bids_path, 'derivatives','stats',['sub-' sub_label], ['sub-' sub_label '_ses-ieeg01_dist_angle_stats.mat']);
load(statspath);

% Where we are saving figure
outpath=fullfile(bids_path, 'derivatives','stats',['sub-' sub_label]);

%% Hippocampus

hippocampus=[limbic_dist_stats.hippocampus_dist];
x=electrodes;
g(1, 1)=gramm('x', x, 'y', hippocampus);
g(1, 1).stat_summary('geom', {'area'});
g(1, 1).set_title(['Distance to Hippocampus sub-' sub_label]);
g(1, 1).set_names('x','Electrode Contact','y', 'Distance (mm)');

hippocampus_body=[limbic_dist_stats.hippocampus_body_dist];
hippocampus_tail=[limbic_dist_stats.hippocampus_tail_dist];
hippocampus_head=[limbic_dist_stats.hippocampus_head_dist];

y=[hippocampus_body, hippocampus_tail, hippocampus_head];
tail=repmat({'Tail'}, length(limbic_dist_stats), 1);
body=repmat({'Body'}, length(limbic_dist_stats), 1);
head=repmat({'Head'}, length(limbic_dist_stats), 1);
color=[body; tail; head];
x=repmat(x, 1, 3);

g(1, 2)=gramm('x', x, 'y', y, 'color', color);
g(1, 2).stat_summary('geom', {'area'});
g(1, 2).set_title(['Distance to Hippocampus Subfields sub-' sub_label]);
g(1, 2).set_names('x','Electrode Contact','y', 'Distance (mm)');


figure('Position',[100 100 800 550]);
g.draw();

outname=['sub-' sub_label 'dist2hippocampus'];
g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');


%% Create histogram plots
% Pull out all length values for each electrode n.b can probably be more
% efficient

for kk=1:length(tracks)

    clear g;
    close all;
    mindist=[];

    for ii=[1:17]
        for jj=1:length(limbic_dist_stats(ii).trackstats(kk).mindist)
            tmp=limbic_dist_stats(ii).trackstats(kk).mindist{jj};
            mindist=[tmp; mindist];
        end
        ind=find(mindist<4);
        pct=100*length(ind)/length(mindist);
        colmap=zeros(length(mindist), 1) + 1;
        colmap(ind)=2;
        
        trkname=limbic_dist_stats(ii).trackstats(kk).name;
        g(ceil((ii)/3),mod(ii-1, 3) + 1)=gramm('x', mindist, 'color', colmap);
        g(ceil((ii)/3),mod(ii-1, 3) + 1).set_names('color','Under/Over','y','Streamline Frequency','x','Nearest Distance (mm)');
        g(ceil((ii)/3),mod(ii-1, 3) + 1).stat_bin('geom','overlaid_bar');
        g(ceil((ii)/3),mod(ii-1, 3) + 1).set_title(['Electrode Contact: ' electrodes{ii} '; Percent under 4mm: ' num2str(pct)]);
        
        mindist=[];
    end

    g.set_title(['Minimum distances to ' trkname ' sub-' sub_label]);
    figure('Position',[100 100 800 600]);
    g.geom_vline('xintercept',4);
    g.draw();
    outname=['sub-' sub_label '_trkdist_hist_' trkname];
    g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');
    
end


