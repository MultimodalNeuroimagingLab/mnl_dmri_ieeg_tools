function addElectrode(elecmatrix, color, fitspline, a, pos)

%   Jordan Bilderbeek Jun 8 2023; updated August 7
%
%   addElectrode will plot colored spheres based on the points given in
%   elecmatrix. this function is useful for overlaying spheres on top of
%   electrode contacts in order to visually illustrate radial current
%   spread
%   
%   INPUTS:
%       a) elecmatrix - matrix of points with x y z positions corresponding to
%       the centroid of an electrode contact
%       b) color - color of sphere
%       c) fitspline - if fitspline==1; we will fit a spline between the
%       centroid positions and plot the line between them. this is not needed
%       if we are running render_dbs_lead function call, but can be useful for
%       quick illustration
%       d) a - alpha of the dots
%       e) pos - list of character tags that can be added as text near the
%       contacts. For example ('LA1', 'LA2', 'LA3', 'LA4') will add text to the
%       corresponding contacts (as long as they are passed in the same order as
%       elecmatrix. 
%
%% Spline Fitting

%Radius of sphere
r=2;

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
%Plotting the sphere
for ii=1:size(coordinates, 1)
    [x,y,z]=sphere;
    surf(x*r+coordinates(ii, 1), y*r+coordinates(ii,2), z*r+coordinates(ii, 3), 'FaceColor', color, 'EdgeColor', 'none');
    alpha(a);
    %text(coordinates(ii, 1), coordinates(ii,2), r+coordinates(ii, 3), num2str(pos(ii)), 'Color','k','FontSize',14, 'HorizontalAlignment','center','VerticalAlignment','middle')
end
xlabel('x'), ylabel('y'), zlabel('z');

end

