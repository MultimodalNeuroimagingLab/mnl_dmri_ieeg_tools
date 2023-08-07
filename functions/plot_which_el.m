function [coords, tag]=plot_which_el(elStruct)

%   Jordan Bilderbeek July 21 2023
%
%   Function to prompt user input for which electrode based on electrode
%   name. Will search through the structure based on input and index the
%   coords out.

%   INPUTS:
%       a) elStruct - electrode structure output from sEEG sorter
%
%   OUTPUTS:
%       a) coords - Nx3 xyz of coords to all of the electrode contacts on
%       one lead. can be used as an input into render_dbs_lead
%       b) tag - takes the mean of xy components and determins which
%       hemisphere we are in. as most sEEG are bilateral this is useful
%
%   USAGE: coords=plot_which_el(mysEEGsortedStruct)
%          
%          [coords, tag]=plot_which_el(mysEEGsortedStruct)
%           if tag='L'
%               render left gifti
%           else
%               render right gifti
%           end
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

