function projpoint=projectPoint2Line(point, lp1, lp2)

%   Jordan Bilderbeek July 6
%
%   Helper function that takes a point and projects it onto a line. The
%   intended use is for when we have a PC axis from linreg3 output - we can
%   then project the electrode contacts onto the PC axis (where lp1 and lp2
%   are the respective start and end points) to form a straight line.
%
%   INPUTS:
%       a) point - xyz of point to be projected
%       b) lp1 - xyz of line point 1 (start of pc axis)
%       c) lp2 - xyz of line point 2 (end of px axis)
%
%   OUTPUTS:
%       a) projpoint - xyz of projectedpoint

%% projectPoint2Line

%direction vector of the line
direc=lp2-lp1;
vec=point-lp1;

%projection scalar
projection_scalar=dot(vec, direc) / dot(direc, direc);
projpoint=lp1+projection_scalar *direc;

end