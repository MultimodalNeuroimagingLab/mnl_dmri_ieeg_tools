function [total_distance, distances] = trk_distance(x, y, z, plot)

%   Jordan Bilderbeek August 4 2023
%
%   trk_distance has the function of taking the x y z coordinates of an
%   individual streamline, and calculating the distance of the streamline 
%   along these points. this can be used to theoretically calculate the 
%   distance between two electrode contacts if we project them onto the 
%   track, and then clip the track at those values. we do this by fitting 
%   an upsampled spline, then taking the difference between the points for 
%   x, y, z. Then use euclidean distance between the upsampled points, and 
%   sum the individual euclideandistances. We can check the spline fit if 
%   plot==1;
%
%   INPUTS:
%       a) x - x coordinate of streamline
%       b) y - y coordinate of streamline
%       c) z - z coordinates of streamline
%       d) plot - optional call if plot==1 in order to validate a proper
%       spline fitting
%
%   OUTPUTS: total_distance - the total euclidean distance between all of
%   the xyz point array

%% trk_distance

jitter_amount=1e-6;
jitter=rand(size(x)) * jitter_amount - jitter_amount/2;
x=x+jitter;
y=y+jitter;
z=z+jitter;

%Calculate distance
distances=sqrt(diff(x).^2 + diff(y).^2 + diff(z).^2);
total_distance=sum(distances);

if plot==1
    figure()
    plot3(x, y, z, 'ro');
    hold on;
    plot3(xx, yy, zz, 'b-');
    legend('Original Track Points', 'Spline')
    title(['Spline through points: total distance ' total_distance ' mm']);
    grid on;
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
end

distances={distances};
end

