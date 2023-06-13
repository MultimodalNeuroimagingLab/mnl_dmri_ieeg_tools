function list=retrieve_row_key_letter_v2(table, alpha_cell)
    
%   Jordan Bilderbeek June 13 2023

%   Re-write of retreve_row_key_letter. Uses regexprep to eliminate
%   matching problems (such as LA and LAL being clustered into the same bin
%   as they have the same LA prefix). Code is self-explanatory (can see
%   prev version for methodology if needed). 

%   We make the assumption that there exists an electrode AA1, AA2 to AAn (on a lead!) 
%   such that n is a CONTINUOUS positive integer. If, depending on
%   TSV curation, we start skipping electrodes instead of assigning NaN's
%   this would fail (ex. suppose we have AA1-AA5 and AA9-AA12; we would
%   create AA1-AA12 which would give false locations to the plotter). 
%   

unique_alphas=unique(table.name);
unique_alpha_cell=unique(alpha_cell);
unique_alpha_cell=table2cell(unique_alpha_cell);
processed_alphas={};

list={};
for ii=1:size(unique_alpha_cell, 1)
    alpha=unique_alpha_cell{ii};
    alpha=regexprep(alpha, '[\d"]', ''); % nice tool to use in this case

    if ismember(alpha, processed_alphas)
        continue
    end

    alpha_indexes=strfind(unique_alphas, alpha);
    alpha_indexes=~cellfun('isempty', alpha_indexes);
    relevant_alphas=unique_alphas(alpha_indexes);

    numeric_values=regexp(relevant_alphas, '\d+', 'match');
    numeric_values=cellfun(@(c)str2double(c{1}), numeric_values);

    max_val=max(numeric_values);
    alpha_list=cell(max_val, 1);
    for jj=1:max_val
        alpha_list{jj}=[alpha, num2str(jj)]; %brittle assumption
    end       
    list=[list; alpha_list]; 
    
    processed_alphas=[processed_alphas, alpha]; %Avoids repeats; likely overkill because we can unique(foo, 'static').
end
    
end
            
    
