function custom_legend(trk_file, colors, sub_label, ifseg)

%   Jordan Bilderbeek July 10 2023; updated August 7
%
%   Custom legend plotter that formats the trk_files to get the track name
%   and pairs it with its respective color. We then create a legend with
%   the track color and name to overlay on DBS figures. ifseg tag will add
%   annotations for Hippocampus and ANT into the figure with corresponding
%   colors
%
%   INPUTS:
%       a) trk_file - fullpath file to cell array of tracks
%       b) colors - output of validatecolor(x, 'multiple'); should be a 3xN
%       of 0-1 color values where N is the number of colors
%       c) sub_label - subject label string to project on the legend
%       d) ifseg - tag to add Hip/ANT annotations in addition to the other
%       tracks
%

    
%% custom_legend

track_fileparts=regexp(trk_file, '/', 'split'); %split by filesep
alltracks={};
figure(1); hold on;
for ii=1:length(trk_file)
    fileparts=track_fileparts{ii}; %get fileparts for one track
    tmp=regexprep(fileparts{end}, '.trk', ''); %regex the .trk out
    alltracks{ii}=regexprep(tmp, '_', ' ');
    %L(ii)=plot(nan, nan, 'Color', colors{ii}, 'LineWidth', 8); %create nan line
    L(ii)=plot(nan, nan, 'Color', colors(ii, :), 'LineWidth', 8); %create nan line
end

%% ifseg opt

if ifseg
    alltracks{ii+1}='Hippocampus Segmentation';
    L(ii+1)=plot(nan, nan, 'Color', colors(ii+1, :), 'LineWidth', 8);
    
    alltracks{ii+2}='Ventral ANT Segmentation';
    L(ii+2)=plot(nan, nan, 'Color', colors(ii+2, :), 'LineWidth', 8);
    
    %alltracks{ii+2}='CM Segmentation';
    %L(ii+2)=plot(nan, nan, 'Color', colors(ii+2, :), 'LineWidth', 8);
    
    alltracks{ii+3}='Dorsal ANT Segmentation';
    L(ii+3)=plot(nan, nan, 'Color', colors(ii+3, :), 'LineWidth', 8);
    
    %alltracks{ii+3}='CL Segmentation';
    %L(ii+3)=plot(nan, nan, 'Color', colors(ii+3, :), 'LineWidth', 8);
    
    alltracks{ii+4}='Medial ANT Segmentation';
    L(ii+4)=plot(nan, nan, 'Color', colors(ii+4, :), 'LineWidth', 8);
    
    lgd=legend(L(1:ii+4), alltracks, 'Interpreter', 'none', 'FontSize', 18); %create legend
    %lgd=legend(L(1:ii+3), alltracks, 'Interpreter', 'none', 'FontSize', 18); %create legend
else
    lgd=legend(L(1:ii), alltracks, 'Interpreter', 'none', 'FontSize', 18); 
end

title(lgd, ['ROIs: ' sub_label])
