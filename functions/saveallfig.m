function saveallfig(varargin)

%   Jordan Bilderbeek August 8
%
%   Search through all open figures and save them to a directory input
%
%   INPUT: directory where you want to save open matlab figures, if none 
%   we default to a desktop folder titled MatlabFigures
%   USAGE: saveallfig(path/to/save/figures)

%%  saveallfig

tic
figHandles=findall(0, 'Type', 'Figure');

if isempty(figHandles)
    disp('No open figures');
    return;
end

if isempty(varargin)
    dir=fullfile('~', 'Desktop', 'MatlabFigures');
else
    dir=varargin{1};
end

if ~exist(dir, 'dir') %mkdir if does not exist
    mkdir(dir)
end

for ii=1:length(figHandles)
    figHandle=figHandles(ii);

        for filenum=1:1000
            figName=['Figure_', num2str(filenum)]; %we iterate through the loop and concat filenummer to the end; break when we havent saved that number yet
            savePath=(fullfile(dir, [figName '.png']));

            if ~exist(savePath,'file')>0
                saveas(figHandle, savePath, 'png');
                break;
            end
        end
end

disp(['All figures saved in ' num2str(toc) ' sec']);

end

