function all_electrodes=retrieve_row_by_labels(labels, labelstable)
  
%   Jordan Bilderbeek Jun 8 2023
%
%   Inputs: labels, labelstable
%       labels are the electrode labels (such as LA1, LA2, LA3). we pull
%       the labels from retrieve_row_key_letter function which tells us
%       which electrode labels are in out regions of interest
%       labelstable is the tsv table we pull from with the table
%
%       result is the full electrode list for roi... i.e if you give LA3 as
%       input the output will be LA1-LA
%   Usage: [electrode]=retrieve_row_key_letters(row, loc_info)
%   

%all_electrodes=array2table(zeros(20, numel(labels)));
labels=table2array(labels);
for ii=1:numel(labels)
    prefix=labels{ii}(1:2);
    mask=startsWith(labelstable.name, prefix);
    matchingRows=labelstable(mask, 1);
    all_electrodes(:, ii)=matchingRows;

end

end

