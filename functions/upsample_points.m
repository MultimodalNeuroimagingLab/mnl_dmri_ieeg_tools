function upsampled_spline_points=upsample_points(varargin)

%   Jordan Bilderbeek Jul 3
%
%   A function that will linearly interpolate to upsample the linreg3
%   points with the extrapolated trajectory in order to ensure smooth 
%   plotting. Upsample factor can be increased - more comp time, 
%   but electrode tends to look visually better.
%
%   Upsample factor = 1000 can probably be used for nice figs. Also with
%   boundary layer will take awhile. Turn to 10 if you just want to see the
%   quick render. 
%
%   INPUTS:
%       a) varagin{1} - list of electrode contact xyz that we want to
%       linear interp between
%       b) varargin{2} - upsample factor (amount of * we want to upsample
%       the points
%       c) varargin{3} - used as an input check via nargin to see if we
%       want to call the optional plotter (default 'plot)
%
%   OUTPUTS:
%       a) upsapmled_spline_points - arr of upsampled points
%
    

%% Upsampling
spline_points=varargin{1};
upsample_factor=varargin{2};

%parameterization of the points
original_param = 1:size(spline_points, 1);

%new parameterization with more points
new_param = linspace(1, size(spline_points, 1), upsample_factor * size(spline_points, 1) - upsample_factor + 1);

%linear interp
x_upsampled = interp1(original_param, spline_points(:, 1), new_param, 'linear');
y_upsampled = interp1(original_param, spline_points(:, 2), new_param, 'linear');
z_upsampled = interp1(original_param, spline_points(:, 3), new_param, 'linear');

upsampled_spline_points = [x_upsampled', y_upsampled', z_upsampled'];

if nargin > 2
    subplot(2,1,2)
    plot3(spline_points(:, 1), spline_points(:, 2), spline_points(:, 3), 'rx-', 'MarkerSize', 15); hold on;
    plot3(upsampled_spline_points(:, 1), upsampled_spline_points(:, 2), upsampled_spline_points(:, 3), 'bo-');
    legend('Original Points', 'Upsampled Points');
    xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
    title('Original vs Upsampled Trajectory (with extrapolation point)');
    grid on;
end

upsampled_spline_points=upsampled_spline_points'; %change here instead of in the whole rest of function
end