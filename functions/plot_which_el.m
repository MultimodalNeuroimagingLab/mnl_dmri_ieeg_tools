function [coords, tag]=plot_which_el(elStruct)

%   Jordan Bilderbeek July 21 2023
%
%   Function to prompt user input for which electrode based on electrode
%   name. Will search through the structure based on input and index the
%   coords out.
%

%% plot_which_el

disp('Which sEEG lead would you like to plot? Your options are:')
for ii=1:length(elStruct)
    disp(elStruct(ii).name);
end
out=input('', "s");

for ii=1:length(elStruct)
    name=elStruct(ii).name;
    if name==out
        coords=elStruct(ii).positions; %search for input
    end
end

side=mean(coords(:,1)); %determine if we are on L or R side to pull tracks and gifti file
if side < 0
    tag='L';
else
    tag='R';
end

end

