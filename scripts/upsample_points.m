function upsampled_spline_points=upsample_points(spline_points, upsample_factor)

%   Jordan Bilderbeek Jul 3

%   A function that will linearly interpolate to upsample the linreg3 points with the extrapolated
%   trajectory in order to ensure smooth plotting. Upsample factor can be
%   increased (more comp time, but electrode tends to look visually better.

%   Upsample factor = 1000 can probably be used for nice figs. Also with
%   boundary layer will take awhile. Turn to 10 if you just want to see the
%   quick render. 

%% Upsampling

%parameterization of the points
original_param = 1:size(spline_points, 1);

%new parameterization with more points
new_param = linspace(1, size(spline_points, 1), upsample_factor * size(spline_points, 1) - upsample_factor + 1);

%linear interp
x_upsampled = interp1(original_param, spline_points(:, 1), new_param, 'linear');
y_upsampled = interp1(original_param, spline_points(:, 2), new_param, 'linear');
z_upsampled = interp1(original_param, spline_points(:, 3), new_param, 'linear');

upsampled_spline_points = [x_upsampled', y_upsampled', z_upsampled'];

subplot(2,1,2)

plot3(spline_points(:, 1), spline_points(:, 2), spline_points(:, 3), 'rx-', 'MarkerSize', 15); hold on;
plot3(upsampled_spline_points(:, 1), upsampled_spline_points(:, 2), upsampled_spline_points(:, 3), 'bo-');
legend('Original Points', 'Upsampled Points');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
title('Original vs Upsampled Trajectory (with extrapolation point)');
grid on;

upsampled_spline_points=upsampled_spline_points'; %change here instead of in the whole rest of function
end