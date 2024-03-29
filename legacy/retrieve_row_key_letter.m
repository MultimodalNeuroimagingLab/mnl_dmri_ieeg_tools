function [result]=retrieve_row_key_letter(letters, anatomicaltab)
    
%   Jordan Bilderbeek Jun 8 2023
%
%   INPUTS
%       a) letters - are a part of the Destrieux label for a track of
%       interest
%       b) anatomicaltab - is the tsv table we pull from with the table
%   OUTPUTS
%       a) row - the row that the destriux label tsv contains the letters
%
%   USAGE: [row]=retrieve_row_key_letters('cing', loc_info)
%   

%% retrieve_row_key_letters

if letters=='pall'
    result=anatomicaltab(1:end-22, 1);
else 
    mask=contains(anatomicaltab.Destrieux_label_text, letters);
    result= anatomicaltab(mask, 1);
    %result=table2array(result);
end
end
    
