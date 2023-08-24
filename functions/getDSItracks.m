function [Ltracks, Rtracks]=getDSItracks(varargin)

%   Jordan Bilderbeek July 6 2023; updated August 3
%
%   Helper function to pull the .trk.gz files based on a given path input.
%   Will separate them into R and L tracks. If the track is not in a given
%   hemi, we will add it to the left side (ex: corpus callosum).
%
%
%   INPUTS: 
%       a) varargin{1} - fullfile path to the parent directory which houses
%       all your .trk files (can have both L and R files)
%       b) varargin{2} - optional call to just search for .trk
%
%   OUTPUTS: 
%       a) Ltracks - fullfile paths to your L tracks
%       b) Rtracks - fullfile paths to your R tracks
%
%   USEAGE: [Ltracks, Rtracks]=getDSItracks('path/to/dsi/parent/dir')


%% getDSItracks

if nargin>1
    pattern=fullfile(varargin{1}, '*.trk'); %folder doesnt have zipped files or we assume they are already unzipped
else
    pattern=fullfile(varargin{1}, '*.trk.gz'); %Search for .trk.gz
end

theFiles=dir(pattern); %search dir for the pattern

Ltracks={};
Rtracks={};
for ii=1:length(theFiles) %loop through files and add name to L or R output
    baseFileName=theFiles(ii).name;
    fullFileName=fullfile(varargin{1}, baseFileName);
    if contains(baseFileName, '_R') % Sort between L and R
        Rtracks{end+1}=fullFileName;
    else
        Ltracks{end+1}=fullFileName;
    end
    
end


