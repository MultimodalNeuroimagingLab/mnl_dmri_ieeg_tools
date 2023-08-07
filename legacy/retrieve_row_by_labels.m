function all_electrodes=retrieve_row_by_labels(labels, labelstable)
  
%   Jordan Bilderbeek Jun 8 2023
%
%   Function that returns full electrode list for a given roi. If you give
%   input of a label (such as LA3) the output will be LA1-LAn.
%
%   INPUTS: 
%       a) labels - labels are the electrode labels (ex: LA1, LA2, LA3).
%       we pull the labels from retrieve_row_key_letter function which 
%       tells us which electrode labels are in out regions of interest.
%       
%       b) labelstable- labelstable is the tsv table that houses all the
%       electrode contact information and destrieux labels
%
%   OUTPUTS: all_electrodes=
%
%   USAGE: [electrode]=retrieve_row_key_letters(row, loc_info)
%   
%% retrieve_row_by_labels

%all_electrodes=array2table(zeros(20, numel(labels)));
labels=table2array(labels);
for ii=1:numel(labels)
    prefix=labels{ii}(1:2);
    mask=startsWith(labelstable.name, prefix);
    matchingRows=labelstable(mask, 1);
    all_electrodes(:, ii)=matchingRows;

end

end

