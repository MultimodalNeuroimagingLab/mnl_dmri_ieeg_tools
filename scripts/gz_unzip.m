function [out_Ltracks, out_Rtracks]=gz_unzip(Ltracks, Rtracks)

%   Jordan Bilderbeek July 6 2023

%   Helper function to unzip dsistudio track files and prep them for AFQ
%   rendering. 


%% gz_unzip

% Regex the gz handles
out_Ltracks=regexprep(Ltracks, '.gz', '');
out_Rtracks=regexprep(Rtracks, '.gz', '');

% Unzip L tracks
for ii=1:length(Ltracks)
    if ~exist(out_Ltracks{ii}, 'file')
        try
            gunzip(Ltracks{ii});
        catch
            disp(['Warning, zipped file does not exist: ' Ltracks{ii}]);
            return;
        end
    end
end

% Unzip R tracks
for ii=1:length(Rtracks)
    if ~exist(out_Rtracks{ii}, 'file')
        try
            gunzip(Rtracks{ii});
        catch
            disp(['Warning, zipped file does not exist: ' Rtracks{ii}]);
            return;
        end
    end
end

end