function videowriter(x, y, outname, xaxis, yaxis, tit)

%   Jordan Bilderbeek Aug 2 2023
%
%   Plot 2D lines and turn into a movie, saved into outname (as filepath).
%  
%   INPUTS:
%       a) x - x points to be plotted
%       b) y - y points to be plotted
%       c) outname - filepath for saving the video
%       d) xaxis - label for xaxis
%       e) yaxis - label for yaxis
%       f) tit - label for title
%
%% videowriter

figure;
axis tight;
xlim([min(x), max(x)]);
ylim([min(y), max(y)]);
set(gca, 'FontSize', 12);

videoFile=VideoWriter(outname);
videoFile.FrameRate=24;
open(videoFile)
    ax=gca;
    ax.Color=[.9, .9, .9];
for ii=1:length(x)
    xlim([min(x), max(x)]); %keep recalling the lims to not stretch on every iter, same with title and labels
    ylim([min(y), max(y)]);
    title(tit)
    xlabel(xaxis)
    ylabel(yaxis)
    ax=gca;
    ax.Color=[.9, .9, .9];
    plot(x(1:ii), y(1:ii), 'b', 'LineWidth', 2);
    hold on;
    plot(x(ii), y(ii), 'ro', 'MarkerSize', 8); %plot red point to show how we are changing with each iter
    frame=getframe(gcf);
    writeVideo(videoFile, frame);
end

close(videoFile)

end