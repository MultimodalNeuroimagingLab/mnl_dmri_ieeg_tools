function custom_legend(trk_file, colors, sub_label)

%   Jordan Bilderbeek July 10 2023

%   Custom legend plotter that formats the trk_files to get the track name
%   and pairs it with its respective color. We then create a legend with
%   the track color and name to overlay on DBS figures. 

%% custom_legend

track_fileparts=regexp(trk_file, '/', 'split'); %split by filesep
alltracks={};

figure(1); hold on;
for ii=1:length(trk_file)
    fileparts=track_fileparts{ii}; %get fileparts for one track
    alltracks{ii}=regexprep(fileparts{end}, '.trk', ''); %regex the .trk out
    L(ii)=plot(nan, nan, 'Color', colors{ii}, 'LineWidth', 8); %create nan line
end

lgd=legend(L(1:ii), alltracks, 'Interpreter', 'none', 'FontSize', 18); %create legend
title(lgd, ['Tracks Visualized: ' sub_label])
