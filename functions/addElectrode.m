function addElectrode(elecmatrix, elecsize, color, fitspline, a)

%   Jordan Bilderbeek Jun 8 2023
%
%   Inputs: elecmatrix, elecsize
%       elecmatrix is a 3D matrix of one individual electrode positions
%       elecsize is the size of electrodes
%   
%   Code will fit a spline between the x,y,z coordinates and plot spheres with a lead extending 
%   If we use the render_dbs_lead function we dont need to fit the spline
%   (set as 0)

%% Spline Fitting
coordinates=sortrows(elecmatrix, 3);
if fitspline==1
    t=1:size(coordinates, 1);
    t2=[linspace(1, size(coordinates, 1), 100), linspace(size(coordinates, 1), size(coordinates, 1) + 5, 100)];

    spline_x=ppval(spline(t, coordinates(:, 1)), t2);
    spline_y=ppval(spline(t, coordinates(:, 2)), t2);
    spline_z=[ppval(spline(t, coordinates(:, 3)), t2(1:100)), linspace(coordinates(end, 3), coordinates(end, 3)+5, 100)];

    hold on;
    plot3(spline_x, spline_y, spline_z, 'LineWidth', 2);
end
%% Plotting    
    
%Radius of sphere
r=elecsize;

%Plotting the sphere
for ii=1:size(coordinates, 1)
    [x,y,z]=sphere;
    surf(x*r+coordinates(ii, 1), y*r+coordinates(ii,2), z*r+coordinates(ii, 3), 'FaceColor', color, 'EdgeColor', 'none');
    alpha(a);
end
xlabel('x'), ylabel('y'), zlabel('z');

end

