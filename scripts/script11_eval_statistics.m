%   Jordan Bilderbeek July 26 2023
%
%   A script to evaluate the values that we calculate in
%   script08_calc_statistics. Currently supports plotting using the gramm
%   toolbox (ggplot like plotting). 
%

subnum=2;
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
load(dsipath);
outpath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','figs',['sub-' sub_label]);

%% 3x3 angle histogram plot

[valueMatrix, xyPairs, numValues] = analyzeStruct(el, length(el), length(el(1).trackstats));

for ii=1:numValues
    angles=[];
    for jj=1:length(el(xyPairs(ii, 1)).trackstats(xyPairs(ii, 2)).angle)
        tmp=el(xyPairs(ii, 1)).trackstats(xyPairs(ii, 2)).angle{jj};
        angles=[tmp; angles];
    end

subplot(4, 4, ii)

polarhistogram(angles)
title(['sub-' sub_label ' ' el(xyPairs(ii, 1)).trackstats(xyPairs(ii, 2)).name], 'Interpreter', 'none');
subtitle(['Polar Histogram ' el(xyPairs(ii, 1)).name])

angles=[];
end

%% 2x2 distance to ROI plot

% Define ROI regions - ventral, dorsal, and medial ANT (left)
AV_left=[el(1).AV_l_dist, el(2).AV_l_dist, el(3).AV_l_dist, el(4).AV_l_dist];
AD_left=[el(1).AD_l_dist, el(2).AD_l_dist, el(3).AD_l_dist, el(4).AD_l_dist];
AM_left=[el(1).AM_l_dist, el(2).AM_l_dist, el(3).AM_l_dist, el(4).AM_l_dist];

% Call the plotter and create gramm struct
y=[AV_left, AD_left, AM_left];
color={'AV', 'AV', 'AV', 'AV', 'AD', 'AD', 'AD', 'AD', 'AM', 'AM', 'AM', 'AM'};
x={'LA1', 'LA2', 'LA3', 'LA4', 'LA1', 'LA2', 'LA3', 'LA4','LA1', 'LA2', 'LA3', 'LA4'};
g(1, 1)=gramm('x', x, 'y', y, 'color', color);
g(1, 1).stat_summary('geom', {'area'});
g(1, 1).set_title('Distance to Left ANT');
g(1, 1).set_names('x','Electrode Contact','y', 'Distance (mm)')

% Define ROI regions - ventral, dorsal, and medial ANT (right)
AV_right=[el(9).AV_r_dist, el(10).AV_r_dist, el(11).AV_r_dist, el(12).AV_r_dist];
AD_right=[el(9).AD_r_dist, el(10).AD_r_dist, el(11).AD_r_dist, el(12).AD_r_dist];
AM_right=[el(9).AM_r_dist, el(10).AM_r_dist, el(11).AM_r_dist, el(12).AM_r_dist];

% Call the plotter and create gramm struct
y=[AV_right, AD_right, AM_right];
color={'AV', 'AV', 'AV', 'AV', 'AD', 'AD', 'AD', 'AD', 'AM', 'AM', 'AM', 'AM'};
x={'LA1', 'LA2', 'LA3', 'LA4', 'LA1', 'LA2', 'LA3', 'LA4','LA1', 'LA2', 'LA3', 'LA4'};
g(1, 2)=gramm('x', x, 'y', y, 'color', color);
g(1, 2).stat_summary('geom', {'area'});
g(1, 2).set_title('Distance to Right ANT');
g(1, 2).set_names('x','Electrode Contact','y', 'Distance (mm)')

% Left hippocampus & plotter
hippocampus_left=[el(5).hippocampus_l_dist, el(6).hippocampus_l_dist, el(7).hippocampus_l_dist, el(8).hippocampus_l_dist];
x={'LH1', 'LH2', 'LH3', 'LH4'};
g(2, 1)=gramm('x', x, 'y', hippocampus_left);
g(2, 1).stat_summary('geom', {'area'});
g(2, 1).set_title('Distance to Left Hippocampus');
g(2,1).set_names('x','Electrode Contact','y', 'Distance (mm)')

% Right hippocapmus & plotter
hippocampus_right=[el(13).hippocampus_r_dist, el(14).hippocampus_r_dist, el(15).hippocampus_r_dist, el(16).hippocampus_r_dist];
x={'RH1', 'RH2', 'RH3', 'RH4'};
g(2, 2)=gramm('x', x, 'y', hippocampus_right);
g(2, 2).stat_summary('geom', {'area'});
g(2, 2).set_title('Distance to Right Hippocampus');
g(2,2).set_names('x','Electrode Contact','y', 'Distance (mm)')

g.set_title(['Distances to ROIs: sub-' sub_label]);

figure('Position',[100 100 800 550]);
g.draw();

outname=['sub-' sub_label 'dist2roi'];
g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');
    



%% 3x3 Distance to track histogram plot
for kk=1:length(el(1).trackstats) %number of tracks
    
    clear g;
    close all;
    mindist=[];
    elarr=[];
    elarrmap=[];
    
    for ii=1:8
        for jj=1:length(el(ii).trackstats(kk).mindist)
            tmp=el(ii).trackstats(kk).mindist{jj}; %simpler would be using arrayfun(@(el.trackstats) although a double index?
            mindist=[tmp; mindist];
        end
        ind=find(mindist<4);
        pct=100*length(ind)/length(mindist);
        colmap=zeros(length(mindist), 1) + 1;
        colmap(ind)=2;
        
        totalmap=repmat({el(ii).name}, 1, length(mindist)); % to make the kernel density we need to extract from loop
        elarrmap=[elarrmap, totalmap];
        elarr=[elarr; mindist];
        
        trkname=el(ii).trackstats(kk).name;
        g(ceil((ii+1)/3),mod(ii, 3) + 1)=gramm('x', mindist, 'color', colmap);
        g(ceil((ii+1)/3),mod(ii, 3) + 1).set_names('color', 'Over/Under', 'y', 'Streamline Frequency', 'x', 'Nearest Distance (mm)');
        g(ceil((ii+1)/3),mod(ii, 3) + 1).stat_bin('geom', 'overlaid_bar');
        g(ceil((ii+1)/3),mod(ii, 3) + 1).set_title(['Electrode Contact: ' el(ii).name '; Percent under 4mm: ' num2str(pct)]);
        
        mindist=[];
    end
    
    g(1, 1)=gramm('x', elarr, 'color', elarrmap');
    g(1,1).stat_density();
    g(1,1).set_title('Kernel Density of all Contacts');
    g(1,1).set_names('color','Electrode Contact','y','Frequency','x','Nearest distance to Fornix (mm)');
    figure('Position',[100 100 800 600]);
    g.geom_vline('xintercept',4);
    g.set_title(['Minimum distances to ' trkname ' sub-' sub_label]);
    g.draw();
   
    outname=['sub-' sub_label 'right_trkdist_hist_' trkname];
    g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');
    
end


%%

% %% Lets now target Cingulum_Parahippocampal_Parietal
% % Some subjects may have hippocampal lead closer to this track instead of
% % Fornix
% 
% mindist=[];
% elarr=[];
% elarrmap=[];
% for ii=1:length(el)/2
%     for jj=1:length(el(ii+8).trackstats(4).mindist)
%         tmp=el(ii+8).trackstats(4).mindist{jj};
%         mindist=[tmp; mindist];
%     end
%     ind=find(mindist<4);
%     pct=100*length(ind)/length(mindist);
%     colmap=zeros(length(mindist), 1);
%     colmap=colmap+ii+8;
%     
%     g(ceil((ii+1)/3),mod(ii, 3) + 1)=gramm('x', mindist, 'color', colmap);
%     g(ceil((ii+1)/3),mod(ii, 3) + 1).set_names('color','Electrode Number','y','Frequency','x','Nearest distance to Parahippocampal Parietal (mm)');
%     g(ceil((ii+1)/3),mod(ii, 3) + 1).stat_bin('fill', 'transparent');
%     g(ceil((ii+1)/3),mod(ii, 3) + 1).set_title(['Electrode Contact: ' num2str(unique(colmap)) '; Percent under 4mm: ' num2str(pct)]);
%     
%     elarrmap=[elarrmap; colmap];
%     elarr=[elarr; mindist];
%     mindist=[];
% end
%     
% g(1, 1)=gramm('x', elarr, 'color', elarrmap);
% g(1,1).stat_density();
% g.set_title(['Minimum distances to R Parahippocampal Parietal: ' sub_label]);
% g(1,1).set_title('Kernel Density of all Contacts');
% g(1,1).set_names('color','Electrode Contact','y','Frequency','x','Nearest distance to Parahippocampal Parietal (mm)');
% figure('Position',[100 100 800 600]);
% g.geom_vline('xintercept',4);
% g.draw();

%% Lets try to make some violin plots

% mindist=[];
% elarr=[];
% elarrmap=[];
% 
% % Pull out all length values for each electrode n.b can probably be more
% % efficient
% 
% for ii=1:length(el)/2
%     for jj=1:length(el(ii+8).trackstats(6).mindist)
%         tmp=el(ii+8).trackstats(6).mindist{jj};
%         mindist=[tmp; mindist];
%     end
% 
%     colmap=zeros(length(mindist), 1);
%     colmap=colmap+ii+8;
%     elarrmap=[elarrmap; colmap];
%     elarr=[elarr; mindist];
%     mindist=[];
% end
%     
% repx=repmat(1, length(elarr), 1);
% 
% g=gramm('y', elarr, 'x', repx, 'Color', elarrmap);
% g.stat_violin('normalization','width');
% g.set_title(['Minimum distances to R fornix: ' sub_label]);
% g.set_names('y','Nearest distance to Fornix (mm)','color','Electrode Number');
% figure('Position',[100 100 800 600]);
% g.geom_hline('yintercept',4);
% g.draw();

% %% Lets make some distance plots for R fornix
% 
% mindist=[];
% elarr=[];
% elarrmap=[];
% 
% % Pull out all length values for each electrode n.b can probably be more
% % efficient
% 
% for ii=1:length(el)/2
%     for jj=1:length(el(ii+8).trackstats(6).mindist)
%         tmp=el(ii+8).trackstats(6).mindist{jj};
%         mindist=[tmp; mindist];
%     end
%     ind=find(mindist<4);
%     pct=100*length(ind)/length(mindist);
%     colmap=zeros(length(mindist), 1);
%     colmap=colmap+ii+8;
%     
%     g(ceil((ii+1)/3),mod(ii, 3) + 1)=gramm('x', mindist, 'color', colmap);
%     g(ceil((ii+1)/3),mod(ii, 3) + 1).set_names('color','Electrode Number','y','CDF','x','Nearest distance to Fornix (mm)');
%     g(ceil((ii+1)/3),mod(ii, 3) + 1).stat_bin('fill', 'transparent');
%     g(ceil((ii+1)/3),mod(ii, 3) + 1).set_title(['Electrode Contact: ' num2str(unique(colmap)) '; Percent under 4mm: ' num2str(pct)]);
%     
%     elarrmap=[elarrmap; colmap];
%     elarr=[elarr; mindist];
%     mindist=[];
% end
%     
% g(1, 1)=gramm('x', elarr, 'color', elarrmap);
% g(1,1).stat_density();
% g.set_title(['Minimum distances to R fornix: ' sub_label]);
% g(1,1).set_title('Kernel Density of all Contacts');
% g(1,1).set_names('color','Electrode Contact','y','Frequency','x','Nearest distance to Fornix (mm)');
% figure('Position',[100 100 800 600]);
% g.geom_vline('xintercept',4);
% g.draw();
% 
