%   Jordan Bilderbeek July 26 2023
%
%   A script to evaluate the values that we calculate in
%   script08_calc_statistics. Currently supports plotting using the gramm
%   toolbox (ggplot like plotting). 
%
%   Assumptions: we assume index positions for the el structure. 
%   el(#).trackstats(1).name=Cingulum_Frontal_Parahippocampal
%   el(#).trackstats(2).name=Cingulum_Frontal_Parietal
%   el(#).trackstats(3).name=Cingulum_Parahippocampal
%   el(#).trackstats(4).name=Cingulum_Parahippocampal_Parietal
%   el(#).trackstats(5).name=Cingulum_Parolfactory
%   el(#).trackstats(6).name=Fornix_L
%% eval_statistics

subnum=1;
[my_subject_labels,bids_path] = dmri_subject_list();
sub_label = my_subject_labels{subnum};

dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
load(dsipath);

%% Lets make some distance plots for R fornix

mindist=[];
elarr=[];
elarrmap=[];

% Pull out all length values for each electrode n.b can probably be more
% efficient

for ii=1:length(el)/2
    for jj=1:length(el(ii+8).trackstats(6).mindist)
        tmp=el(ii+8).trackstats(6).mindist{jj};
        mindist=[tmp; mindist];
    end
    ind=find(mindist<4);
    pct=100*length(ind)/length(mindist);
    colmap=zeros(length(mindist), 1);
    colmap=colmap+ii+8;
    
    g(ceil((ii+1)/3),mod(ii, 3) + 1)=gramm('x', mindist, 'color', colmap);
    g(ceil((ii+1)/3),mod(ii, 3) + 1).set_names('color','Electrode Number','y','CDF','x','Nearest distance to Fornix (mm)');
    g(ceil((ii+1)/3),mod(ii, 3) + 1).stat_bin('fill', 'transparent');
    g(ceil((ii+1)/3),mod(ii, 3) + 1).set_title(['Electrode Contact: ' num2str(unique(colmap)) '; Percent under 4mm: ' num2str(pct)]);
    
    elarrmap=[elarrmap; colmap];
    elarr=[elarr; mindist];
    mindist=[];
end
    
g(1, 1)=gramm('x', elarr, 'color', elarrmap);
g(1,1).stat_density();
g.set_title(['Minimum distances to R fornix: ' sub_label]);
g(1,1).set_title('Kernel Density of all Contacts');
g(1,1).set_names('color','Electrode Contact','y','Frequency','x','Nearest distance to Fornix (mm)');
figure('Position',[100 100 800 600]);
g.geom_vline('xintercept',4);
g.draw();

%% Lets now target Cingulum_Parahippocampal_Parietal
% Some subjects may have hippocampal lead closer to this track instead of
% Fornix

mindist=[];
elarr=[];
elarrmap=[];
for ii=1:length(el)/2
    for jj=1:length(el(ii+8).trackstats(4).mindist)
        tmp=el(ii+8).trackstats(4).mindist{jj};
        mindist=[tmp; mindist];
    end
    ind=find(mindist<4);
    pct=100*length(ind)/length(mindist);
    colmap=zeros(length(mindist), 1);
    colmap=colmap+ii+8;
    
    g(ceil((ii+1)/3),mod(ii, 3) + 1)=gramm('x', mindist, 'color', colmap);
    g(ceil((ii+1)/3),mod(ii, 3) + 1).set_names('color','Electrode Number','y','Frequency','x','Nearest distance to Parahippocampal Parietal (mm)');
    g(ceil((ii+1)/3),mod(ii, 3) + 1).stat_bin('fill', 'transparent');
    g(ceil((ii+1)/3),mod(ii, 3) + 1).set_title(['Electrode Contact: ' num2str(unique(colmap)) '; Percent under 4mm: ' num2str(pct)]);
    
    elarrmap=[elarrmap; colmap];
    elarr=[elarr; mindist];
    mindist=[];
end
    
g(1, 1)=gramm('x', elarr, 'color', elarrmap);
g(1,1).stat_density();
g.set_title(['Minimum distances to R Parahippocampal Parietal: ' sub_label]);
g(1,1).set_title('Kernel Density of all Contacts');
g(1,1).set_names('color','Electrode Contact','y','Frequency','x','Nearest distance to Parahippocampal Parietal (mm)');
figure('Position',[100 100 800 600]);
g.geom_vline('xintercept',4);
g.draw();

%% Lets try to make some violin plots

mindist=[];
elarr=[];
elarrmap=[];

% Pull out all length values for each electrode n.b can probably be more
% efficient

for ii=1:length(el)/2
    for jj=1:length(el(ii+8).trackstats(6).mindist)
        tmp=el(ii+8).trackstats(6).mindist{jj};
        mindist=[tmp; mindist];
    end

    colmap=zeros(length(mindist), 1);
    colmap=colmap+ii+8;
    elarrmap=[elarrmap; colmap];
    elarr=[elarr; mindist];
    mindist=[];
end
    
repx=repmat(1, length(elarr), 1);

g=gramm('y', elarr, 'x', repx, 'Color', elarrmap);
g.stat_violin('normalization','width');
g.set_title(['Minimum distances to R fornix: ' sub_label]);
g.set_names('y','Nearest distance to Fornix (mm)','color','Electrode Number');
figure('Position',[100 100 800 600]);
g.geom_hline('yintercept',4);
g.draw();


