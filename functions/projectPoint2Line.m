function projpoint=projectPoint2Line(point, lp1, lp2)

%   Jordan Bilderbeek July 6

%   Helper function that takes input as a point, and line points 1/2. Will
%   project the point onto the line. 

%% projectPoint2Line

%direction vector of the line
direc=lp2-lp1;
vec=point-lp1;

%projection scalar
projection_scalar=dot(vec, direc) / dot(direc, direc);
projpoint=lp1+projection_scalar *direc;

end