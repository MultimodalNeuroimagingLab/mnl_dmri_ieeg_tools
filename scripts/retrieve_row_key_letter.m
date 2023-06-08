function [result]=retrieve_row_key_letter(letters, anatomicaltab)
    
%   Jordan Bilderbeek Jun 8 2023
%
%   Inputs: letters, anatomicaltab
%       letters are a part of the Destrieux label for a track of
%       interest
%       anatomicaltab is the tsv table we pull from with the table
%   Usage: [row]=retrieve_row_key_letters('cing', loc_info)
%   

    mask=contains(anatomicaltab.Destrieux_label_text, letters);
    result= anatomicaltab(mask, 1);
    %result=table2array(result);
end
    
