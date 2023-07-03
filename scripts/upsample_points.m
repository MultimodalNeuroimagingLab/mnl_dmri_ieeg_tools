function upsampled_spline_points=upsample_points(spline_points, upsample_factor)

%   Jordan Bilderbeek Jul 3

%   A function that will upsample the linreg3 points with the extrapolated
%   trajectory in order to ensure nice plotting. Upsample factor can be
%   increased (more comp time, but better plotting outcome)



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

plot3(spline_points(:, 1), spline_points(:, 2), spline_points(:, 3), 'ro-'); hold on;
plot3(upsampled_spline_points(:, 1), upsampled_spline_points(:, 2), upsampled_spline_points(:, 3), 'bx-');
legend('Original Points', 'Upsampled Points');
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Original and Upsampled Trajectory');
grid on;

upsampled_spline_points=upsampled_spline_points'; %change here instead of in the whole rest of function
end