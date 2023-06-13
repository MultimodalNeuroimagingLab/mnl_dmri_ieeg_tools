function render_dbs_lead(electrode_positions, lead_size, extension_height)

%   Jordan Bilderbeek June 9 2023
%
%   Inputs: electrode_positions, lead_size, extension_height
%       electrode_positions is a N by 3 matrix [x,y,z] of the electrode
%       coordinates. Can be retrieved from locs_info (tsv with electrode
%       positions)
%       lead_size is position between electrodes
%       extension_height is the length for the extension portion of the
%       lead that will extend out of the brain
%   Usage: render_dbs_lead(elecmatrix(ismember(loc_info.name, els_plot'),
%   :), 2, 10)
%
%   Where elecmatrix is the entire matrix of electrode position and
%   els_plot is the name of the electrodes we are interested in. Generally,
%   because we are fitting a spline and plotting the lead, we are looking 
%   for a continued list of electrodes ie LA1, LA2...LAn but we dont want
%   to input multiple electrodes because then the spline and render will be
%   all over the place. 
%  

%% Initialize
lead_radius=1; % in mm
twist_angle=75; % in deg

%num_points=100; % For spline
num_points=size(electrode_positions, 1);

%% Fit the spline

spline_fit=cscvn(electrode_positions');
spline_points=fnplt(spline_fit, num_points);


%% Create lead
hold on;

    function R=axisAngleToRotMat(ax, theta) % axang2rotm in Navigation, Robotics or UAV toolbox...which we dont have
        ct=cos(theta);
        st=sin(theta);
        omct=1-ct;
        x=ax(1); y=ax(2); z=ax(3);
        
        R=[ct + x^2 * omct, x*y*omct-z * st, x*z*omct + y * st; %http://motion.pratt.duke.edu/RoboticSystems/3DRotations.html
            y*x*omct+z * st, ct + y^2 * omct, y*z*omct-x * st;
            z*x*omct-y * st, z*y*omct+x * st, ct + z^2*omct];
    end

for ii=1:size(spline_points, 2)-1
    p1=spline_points(:,ii);
    p2=spline_points(:, ii+1);
    dir=p2-p1;
    len=norm(dir);
    dir=dir/len;
    ax=cross([0 0 -1], dir); %find perp vec
    ax=ax/norm(ax); %div cross by normal
    theta=acos(dot([0 0 -1], dir));
    R=axisAngleToRotMat(ax, theta); %create orthonormal rotation matrix
    
    [X, Y, Z]=cylinder([0 lead_radius]);
    Z=Z*len;
        for jj=1:numel(X)
            vec=R * [X(jj) Y(jj) Z(jj)]';
            X(jj)=vec(1);
            Y(jj)=vec(2);
            Z(jj)=vec(3);
        end
    line_segment=surf(X+p1(1), Y+p1(2), Z+p1(3));
    
    dists=vecnorm((electrode_positions - p1'), 2, 2);
    [closest_dist, ~]=min(dists);
    
    if closest_dist <= lead_size
        set(line_segment, 'FaceColor', 'k', 'EdgeColor', 'none');
    else
        set(line_segment, 'FaceColor', [.75, .75, .75], 'EdgeColor', 'none');
    end
end

%% Adding a tip to the electrode lead
    
p1=spline_points(:, 1); %Similar to above
p2=spline_points(:,2);
dir=p2-p1;
dir=dir/norm(dir);

ax=cross([0 0 -1], dir);
ax=ax/norm(ax);
theta=acos(dot([0 0 -1], dir)); % Where lines 79-82 will adjust the direction and angle
R=axisAngleToRotMat(ax, theta); %create orthonormal rotation matrix

[X,Y,Z]=sphere();
X=X*lead_radius;
Y=Y*lead_radius;
Z=Z*lead_radius;
mask = Z >= 0 & Z<= lead_radius;
X=X.*mask;
Y=Y.*mask;
Z=-Z.*mask;

for ii=1:numel(X)
    vec=R * [X(ii), Y(ii), Z(ii)]';
    X(ii)=vec(1);
    Y(ii)=vec(2);
    Z(ii)=vec(3);
end

tip=surf(X+p2(1), Y+p2(2), Z+p2(3));
set(tip, 'FaceColor', 'k', 'EdgeColor', 'none');

%% Add the extension height region

% top_point=spline_points(:, end);
% twist_radius=lead_radius / 2;
% twist_rotation = axisAngleToRotMat([0 0 1], twist_angle); %create rotation matrix
% twist_length=max(extension_height - top_point(3), 0);
% 
% [X, Y, Z]=cylinder([twist_radius, twist_radius]);
% Z=Z*twist_length;
% 
% for ii=1:numel(X)
%     vec=twist_rotation * [X(ii) Y(ii) Z(ii)]';
%     X(ii)=vec(1);
%     Y(ii)=vec(2);
%     Z(ii)=vec(3);
% end
% 
% twist_cylinder=surf(X + top_point(1), Y + top_point(2), Z + top_point(3));
% set(twist_cylinder, 'FaceColor', [.75 .75 .75], 'EdgeColor', 'none');

end

    




