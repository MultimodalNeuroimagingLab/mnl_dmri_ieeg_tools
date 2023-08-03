function [fg_fromtrk] = strm_angle(fg_fromtrk,roi, size)

%   Jordan Bilderbeek July 19 2023; updated August 3
%
%   Finds streamline points that are within a given window size based on
%   euclidean distance function. We then fit the principal axes to the
%   streamline points, and calculate the angle between the principal axes
%   and a vector based on the electrode contact position (roi) and a
%   projected point onto the line. 
%
%   INPUTS:
%       A) fg_fromtrk: structure created from create_trkstruct output,
%       holds all of the individual fiber information from each track
%       B) roi: x3 xyz of electrode contact centroid 
%       C) size: we fit the PC axis based on some euclidean distance
%       between the streamline and electrode contact - size determines 
%       the largest distance.
%
%   OUTPUTS
%       A) fg_fromtrk: same structure as input; but fg_fromtrk.angle is
%       added with angle measurements in radians.

%% strm_angle

for ii=1:length(fg_fromtrk)
    for jj=1:length(fg_fromtrk(ii).fibers)
        ind=find(fg_fromtrk(ii).distance{jj}<size); %search for points under size parameter
        if length(ind) < 2 %cannot fit PC axis unless we have 2 points
            fg_fromtrk(ii).angle{jj}=NaN;
        else
            fiberpoints=fg_fromtrk(ii).fibers{jj}(:, ind);
            PCaxis=linreg3(fiberpoints'); %fit PC axis
            
            %determine u and v vectors, then take the normal of cross and
            %dot between - atan2 to return angle in radians.
            u=abs(PCaxis(1,:)-PCaxis(2,:));
            v=abs(projectPoint2Line(roi, PCaxis(1,:), PCaxis(2,:))-roi); 
            fg_fromtrk(ii).angle{jj}=atan2(norm(cross(u,v)),dot(u,v));
        end
    end
    
end




end

