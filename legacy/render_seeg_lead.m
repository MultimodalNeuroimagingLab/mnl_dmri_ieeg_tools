function render_seeg_lead(electrode_positions, lead_size, ~)

%   Jordan Bilderbeek June 9 2023
%
%   INPUTS: electrode_positions, lead_size, extension_height
%       a) electrode_positions is a N by 3 matrix [x,y,z] of the electrode
%       coordinates. Can be retrieved from locs_info (tsv with electrode
%       positions)
%       b) lead_size is position between electrodes
%       c) extension_height is the length for the extension portion of the
%       lead that will extend out of the brain
%   USAGE: render_dbs_lead(elecmatrix(ismember(loc_info.name, els_plot'),
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

%% Fit the spline

spline_fit=cscvn(electrode_positions'); 
%If we want to make a longer lead a function like cscvn may cause problems 
spline_points=fnplt(spline_fit);

for i=1:5 %essentially upsampling the spline
    spline_fit=cscvn(spline_points);
    spline_points=fnplt(spline_fit);
end
%% Create lead
hold on;

% axisAngleToRotMat has similar functionality to axang2rotm in Navigation, Robotics or UAV toolbox
% Rotation matrix R allows 3D point to be rotated around ax (axis) by theta
% (angle)
    function R=axisAngleToRotMat(ax, theta) 
        ct=cos(theta);
        st=sin(theta);
        omct=1-ct;
        x=ax(1); y=ax(2); z=ax(3);
        
        R=[ct + x^2 * omct, x*y*omct-z * st, x*z*omct + y * st; %Rodrigues' 
            y*x*omct+z * st, ct + y^2 * omct, y*z*omct-x * st;
            z*x*omct-y * st, z*y*omct+x * st, ct + z^2*omct]; 
    end

for ii=1:size(spline_points, 2)-1
    p1=spline_points(:,ii);
    p2=spline_points(:, ii+1);
    dir=p2-p1; %Find direction of one segment between two individual points
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
        set(line_segment, 'FaceColor', 'k', 'EdgeColor', 'k'); %Used for any line segments that are close to the electrode center
    else
        set(line_segment, 'FaceColor', [.75, .75, .75], 'EdgeColor', [.75, .75, .75]); %Used for any line segments that are not close to the electrode center
    end
end

%% Adding a tip to the electrode lead
    
p1=spline_points(:, 1); %Similar to above
p2=spline_points(:,2);
dir=p1-p2;
dir=dir/norm(dir);

ax=cross([0 0 -1], dir);
ax=ax/norm(ax);
theta=acos(dot([0 0 -1], dir)); % Where lines will adjust the direction and angle
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

end

    




