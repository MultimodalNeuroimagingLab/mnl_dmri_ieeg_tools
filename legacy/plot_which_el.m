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
%       a) coords - struct that can be indexed via coords(#);
%       coords(#).positions contains the Nx3 matrix of xyz
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

%Determine which electrode leads we would like to plot
for ii=1:length(elStruct)
    names(ii)=elStruct(ii).name; %pull all names from the structure
end
disp('Which sEEG lead(s) would you like to plot (ex: RB RC)? Your options are:')
disp(names');
out=input('', "s");
out=split(out);
out=regexprep(out, ',', '');
out=string(out);

%Search for locations
[~, loc]=ismember(out', names);
coords=struct();

%Add the positions to the out structure
for ii=1:length(loc)
    coords(ii).positions=elStruct(loc(ii)).positions;
end
side=mean(coords(1).positions(:,1));
if side < 0
    tag='L';
else
    tag='R';
end

end

