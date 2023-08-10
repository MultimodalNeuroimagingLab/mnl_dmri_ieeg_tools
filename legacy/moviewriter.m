
%   Jordan Bilderbeek August 10
%
%   moviewriter was written in order to create .mp4 files based on .png
%   screenshots of DSI seedtracking outputs
%
%   we read in the png files in the folder variable; resize them and insert
%   a text box. we then perform a linear interpolation between images to
%   give a smooth transition between image 1 and 2. we repeat this for all
%   the images, then write the movie out

%% moviewriter

clear all;
folder='~/Desktop/dsi_figs/sub-01';
outputVideo=VideoWriter('~/Desktop/dsi_figs/sub-01/sub1.mp4', 'MPEG-4');
outputVideo.FrameRate=10;
open(outputVideo);

files=dir(fullfile(folder, '*.png'));
numInterpolatedFrames=10; %number of frames we interpolate between raw images

sz=[700, 900];
for ii=1:length(files)-1
    img1=imread(fullfile(folder, files(ii).name)); %image 1
    img2=imread(fullfile(folder, files(ii+1).name)); %image 2
    
    img1=imresize(img1, sz); %resize as all ss are different sizes
    img2=imresize(img2, sz);
    img1=insertText(img1, [5, 5], files(ii).name, 'FontSize', 18, 'BoxColor', 'white'); %insert box so we know what image were looking at
    writeVideo(outputVideo, im2frame(img1)); %write image 1
    
    
    for tt=1:numInterpolatedFrames
        alpha=tt/(numInterpolatedFrames + 1);
        interpolatedImg=img1 * (1-alpha) + img2 * alpha; %linear interpolation between frames
        writeVideo(outputVideo, im2frame(uint8(interpolatedImg))); %write the interpolated images
    end
end
    
    imgLast=imread(fullfile(folder, files(end).name)); %we interp to the last image, but dont include it; do it here
    imgLast=imresize(imgLast, sz);
    imgLast=insertText(imgLast, [5, 5], files(end).name, 'FontSize', 18, 'BoxColor', 'white');
    writeVideo(outputVideo, im2frame(imgLast))
    close(outputVideo);
    
    