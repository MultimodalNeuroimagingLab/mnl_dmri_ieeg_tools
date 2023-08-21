%% now do all the distances
[my_subject_labels,bids_path] = dmri_subject_list();

colors={'r', 'g', 'b', 'k', 'm'};
all_data=cell(5, 1);

for subject=1:5
    
    sub_label = my_subject_labels{subject};
    dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
    load(dsipath);
    sides=repelem({'l', 'r'}, [8 8]);
    
    all_data{subject}=struct(...
        'hippocampus', {cellfun(@(side, el) el.(['hippocampus_', side, '_dist']), sides, num2cell(el))}, ...
        'AV', {cellfun(@(side, el) el.(['AV_', side, '_dist']), sides, num2cell(el))}, ...
        'AD', {cellfun(@(side, el) el.(['AD_', side, '_dist']), sides, num2cell(el))}, ...
        'AM', {cellfun(@(side, el) el.(['AM_', side, '_dist']), sides, num2cell(el))}, ...
        'names', { {el.name} });
    
%     all_data{subject}=struct(...
%         'hippocampus', {cellfun(@(side, el) el.(['hippocampus_', side, '_dist']), sides, num2cell(el))}, ...
%         'CM', {cellfun(@(side, el) el.(['CM_', side, '_dist']), sides, num2cell(el))}, ...
%         'CL', {cellfun(@(side, el) el.(['CL_', side, '_dist']), sides, num2cell(el))}, ...
%         'names', { {el.name} });
end

%roi={'hippocampus', 'CM', 'CL'};
roi={'hippocampus', 'AD', 'AM', 'AV'};


for ii=1:4

    color=repelem({'MSEL01219','MSEL01942', 'MSEL01957', 'MSEL02004', 'MSEL02375'}, [16 16 16 16 16]);
    %color=repelem({ 'MSEL02004' }, [16]);

    yval=[all_data{1}.(roi{ii}), all_data{2}.(roi{ii}), all_data{3}.(roi{ii}), all_data{4}.(roi{ii}), all_data{5}.(roi{ii})];
    names=[all_data{1}.names, all_data{2}.names, all_data{3}.names, all_data{4}.names, all_data{5}.names];
    
%     yval=[all_data{4}.(roi{ii})];
%     names = all_data{4}.names;
    
    g(ceil(ii/2), mod(ii -1, 2) + 1)=gramm('x', names, 'y', yval, 'color', color);
    g(ceil(ii/2), mod(ii -1, 2) + 1).axe_property('XTickLabelRotation', 45);
    g(ceil(ii/2), mod(ii -1, 2) + 1).stat_summary('geom', {'area'});
    g(ceil(ii/2), mod(ii -1, 2) + 1).set_names('x', 'Electrode Contacts', 'y', 'Minimum distances to ROI (mm)', 'color', 'Subjects');
    g(ceil(ii/2), mod(ii -1, 2) + 1).set_title(['Comparison of minimum distance to ' roi{ii} ' between subjects']);

%     g(1, ii)=gramm('x', names, 'y', yval, 'color', color);
%     g(1, ii).axe_property('XTickLabelRotation', 45);
%     g(1, ii).stat_summary('geom', {'area'});
%     g(1, ii).set_names('x', 'Electrode Contacts', 'y', 'Minimum distances to ROI (mm)', 'color', 'Subjects');
%     g(1, ii).set_title(['Comparison of minimum distance to ' roi{ii} ' between subjects']);

end

outpath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','figs');
outname='all_sub_dist2roi';
figure('Position',[100 100 800 550]);
g.draw;
g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');
    
clear g
%% now all the eboxplots
[my_subject_labels,bids_path] = dmri_subject_list();
names={'Fornix', 'Cingulum_Parolfactory', 'Cingulum_Parahippocampal', 'Cingulum_Parahippocampal_Parietal', 'Cingulum_Frontal_Parietal', 'Cingulum_Frontal_Parahippocampal'};

for namenum=1:length(names)
    tic;
    specific_name=names{namenum};
    clear g
    close all;
    mindist_values=[];
    electrode_labels=[];
    subject_labels=[];
    for ii=1:5
        subnum=ii;

        sub_label = my_subject_labels{subnum};
        dsipath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','dsistudio',['sub-' sub_label], 'stats.mat');
        load(dsipath);

        for elec=1:16
            for track=1:6
                if strcmp(el(elec).trackstats(track).name, specific_name)
                    mindist_cell=el(elec).trackstats(track).mindist;
                    mindist_values=[mindist_values, cell2mat(mindist_cell)];
                    electrode_labels=[electrode_labels; repmat({['Electrode ' el(elec).name]}, length(el(elec).trackstats(track).mindist), 1)];

                    subject_labels=[subject_labels; repmat({['Subject ' sub_label]}, length(el(elec).trackstats(track).mindist), 1)];
                end
            end

        end
    end

    g=gramm('x', electrode_labels, 'y', mindist_values', 'color', subject_labels);
    g.geom_vline('xintercept',0.5:1:16.5,'style','k-');
    g.stat_boxplot('width',0.5,'dodge',1);
    g.set_names('x', 'Electrode Contacts', 'y', 'Minimum distances to track (mm)', 'color', 'Subjects');
    g.set_title(['Comparison of minimum distance to ' specific_name ' between subjects']);

    g.axe_property('XTickLabelRotation', 45);
    g.draw;

    outpath=fullfile(bids_path,'BIDS_subjectsRaw', 'derivatives','figs');

    outname=['all_sub_' specific_name];
    g.export('file_name',outname,'export_path',outpath,'file_type','svg', 'height', 20.3, 'width', 25.6, 'units', 'inches');
    
    disp(['Exported fig ' num2str(namenum) ' in ' num2str(toc) ' sec'])
end
