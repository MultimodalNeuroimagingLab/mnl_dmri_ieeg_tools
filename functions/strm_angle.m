function [fg_fromtrk] = strm_angle(fg_fromtrk,roi, size)

%   Jordan Bilderbeek July 19 2023
%
%   Finds streamline points that are within a given window size based on
%   euclidean distance function. We then fit the principal axes to the
%   streamline points, and calculate the angle between the principal axes
%   and a vector based on the electrode contact position (roi) and a
%   projected point onto the line. 

%% strm_angle

for ii=1:length(fg_fromtrk)
    for jj=1:length(fg_fromtrk(ii).fibers)
        ind=find(fg_fromtrk(ii).distance{jj}<size);
        if length(ind) < 2 %cannot fit PC axis unless we have 2 points
            fg_fromtrk(ii).angle{jj}=NaN;
        else
            fiberpoints=fg_fromtrk(ii).fibers{jj}(:, ind);
            PCaxis=linreg3(fiberpoints');
            u=abs(PCaxis(1,:)-PCaxis(2,:));
            v=abs(projectPoint2Line(roi, PCaxis(1,:), PCaxis(2,:))-roi);
            fg_fromtrk(ii).angle{jj}=atan2(norm(cross(u,v)),dot(u,v));
        end
    end
    
end




end

