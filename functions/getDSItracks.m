function [Ltracks, Rtracks]=getDSItracks(path)

%   Jordan Bilderbeek July 6 2023

%   Helper function to pull the .trk.gz files based on a given path input.
%   Will separate them into R and L tracks. If the track is not in a given
%   hemi, we will add it to the left side (ex: corpus callosum).


%% getDSItracks

pattern=fullfile(path, '*.trk'); %Search for .trk.gz
theFiles=dir(pattern);

Ltracks={};
Rtracks={};

for ii=1:length(theFiles)
    baseFileName=theFiles(ii).name;
    fullFileName=fullfile(path, baseFileName);
    
    if contains(baseFileName, '_R') % Sort between L and R
        Rtracks{end+1}=fullFileName;
    else
        Ltracks{end+1}=fullFileName;
    end
    
end


