function [elStruct] = sEEGsorter(filename)
%   Jordan Bilderbeek July 21 2023
%
%   Function that takes an electrodes.tsv file (sEEG) and sorts based on
%   probe names. We format the .tsv into elStruct which has fields
%   elStruct.name and elStruct.positions which contain the name
%   and the xyz positions.
%
%   Inputs: filename of tsv file
%   Outputs: 1xN struct array with fields name and position. Can index
%   throughout the structure via elStruct(1).name and elStruct(1).positions
%   to get the first electrode name and xyz coordinates

%   When plotting sEEG leads we can do something along the lines of:
%   for ii=1:length(elStruct)
%       render_dbs_lead/render_seeg_lead (elStruct(ii).positions)
%   end

%% sEEGsorter

% First perform regex on name column such that we have every alpha
% separated from the numeric. Then take unique alphas from the list. We
% iterate in a for loop through the uniques - can match the initial list
% and pull out the names and positions based on table indices. 

table=readtable(filename, 'FileType', 'text', 'Delimiter', '\t');
alpha=regexprep(table.name, '[\d"]', '');
unique_alphas=unique(alpha);
coords=table2array(table(:, 2:4));

for ii=1:length(unique_alphas)
    elStruct(ii).name=string(unique_alphas(ii));
    elStruct(ii).positions=rmmissing(coords(find(string(unique_alphas(ii))==string(alpha)), :));
end


end

