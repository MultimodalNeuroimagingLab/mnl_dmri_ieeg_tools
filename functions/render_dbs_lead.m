function render_dbs_lead(electrode_positions, lead_size, extrap_length, invlead)

%   Jordan Bilderbeek June 19 2023; cha
%
%   render_dbs_lead is the main heavylifting function that creates high
%   quality visual leads from Nx3 arrays of electrode positions. Based on
%   contacts, we find the principal component axis, and upsample the
%   electrode position points along the line. We then create the lead by
%   iterating through the upsampled points, finding the direction between
%   them and creating an orthonormal rotation matrix. The rotation matrix
%   is multiplied by a cone (cylinder) to transfer the XYZ positions of the
%   cylinder into the appropriate rotation. We color the cones based on
%   their proximity to the original electrode_positions. This process is
%   repeated for an extrapolation layer, which visually, adds depth to the
%   electrode. 
% 
%   INPUTS:
%       a) electrode_positions - Nx3 array of electrode positions (xyz)
%       b) lead_size - 1/2 the size of the electrode contact
%       c) extrap_length - distance in mm for the length we want to add on
%       the back of the last electrode contact level
%       d) invlead - default 0-1. If 1 we invert the lead direction such
%       that the extrap_length is flipped. 
%
%   Setup changes to variable names:
%       a) lead_radius - generally .4 for sEEG and .635 for DBS electrodes
%       we are plotting.
%       b) upsample_factor - the amount we are upsampling the electrode
%       positions. Upsample factors of 10 will give cheap, cone looking
%       electrode contacts, but will be extremely quick. Used for visual
%       checking. Most renders generally run on an upsample factor of 1000 
%       c) encapsulation_radius - generally set to .2 greater than the lead
%       radius. can be set to be smaller or larger


%% Initialize 
lead_radius=.4; % in mm for sEEG
%lead_radius=.635; %in mm for DBS

%% Fit the electrode positions and upsample

figure(2)
spline_points=linreg3(electrode_positions);
spline_points=sortrows(spline_points, 3, 'descend'); %assumes that leads have upward trajectory

p1=spline_points(1,:); %get first point
p2=spline_points(2,:); %get second point
lead_direction=p2-p1;
lead_direction=lead_direction/norm(lead_direction);

if invlead %invert the lead if necessary
    extrap_point=spline_points(end,:) + extrap_length * lead_direction;
    spline_points=[spline_points; extrap_point];
else
    extrap_point=spline_points(1, :) + extrap_length * -lead_direction;
    spline_points=[extrap_point; spline_points];
end

upsample_factor=50;
spline_points=upsample_points(spline_points, upsample_factor); %upsample points
set(findall(gcf,'-property','FontSize'),'FontSize',24)
%% Create lead

figure(1);
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

encapsulation_radius=lead_radius + .2; %.2mm larger than normal
encapsulation_color=[.725 .725 .768]; %color of encapsulation layer
encapsulation_transparency = .1;

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
    
    [X, Y, Z]=cylinder([0 lead_radius], 50); %will create cone object
    Z=Z*len;
        for jj=1:numel(X)
            vec=R * [X(jj) Y(jj) Z(jj)]';
            X(jj)=vec(1);
            Y(jj)=vec(2);
            Z(jj)=vec(3);
        end
    line_segment=surf(X+p1(1), Y+p1(2), Z+p1(3));
    
    dists=vecnorm((electrode_positions - p1'), 2, 2); %euclidean distance to all electrode positions, find which one we are closest to and the distance
    [closest_dist, ~]=min(dists); %distance to nearest electrode position
    
    if closest_dist <= lead_size %because euclidean distance, lead_size must be 1/2 the contact length
        set(line_segment, 'FaceColor', 'k', 'EdgeColor', 'k'); %Used for any line segments that are close to the electrode center
    else
        set(line_segment, 'FaceColor', [.75, .75, .75], 'EdgeColor', [.75, .75, .75]); %Used for any line segments that are not close to the electrode center
    end

%% Create encapsulation layer
    
%generally a repear from above for the encapsulation layer. 
    [x_encap, y_encap, z_encap]=cylinder([0, encapsulation_radius], 50);
    z_encap=z_encap*len;
    for kk=1:numel(x_encap)
        vec=R*[x_encap(kk) y_encap(kk) z_encap(kk)]';
        x_encap(kk)=vec(1);
        y_encap(kk)=vec(2);
        z_encap(kk)=vec(3);
    end
    encap_segment=surf(x_encap + p1(1), y_encap+p1(2), z_encap+p1(3));
    set(encap_segment, 'FaceColor', encapsulation_color, 'EdgeColor', 'none', 'FaceAlpha', encapsulation_transparency)

end

%% Adding a tip to the electrode lead
if invlead==1
    p1=spline_points(:, 1); %Similar to above
    p2=spline_points(:,2);
else
    p1=spline_points(:, end);
    p2=spline_points(:, end-1);
end

dir=p1-p2;
dir=dir/norm(dir);

ax=cross([0 0 -1], dir);
ax=ax/norm(ax);
theta=acos(dot([0 0 -1], dir));
R=axisAngleToRotMat(ax, theta); %create orthonormal rotation matrix

[X,Y,Z]=sphere();
X=X*lead_radius;
Y=Y*lead_radius;
Z=Z*lead_radius;
mask = Z >= 0 & Z<= lead_radius;
X=X.*mask;
Y=Y.*mask;
%Z=Z*mask;
Z=-Z.*mask;

for ii=1:numel(X)
    vec=R * [X(ii), Y(ii), Z(ii)]';
    X(ii)=vec(1);
    Y(ii)=vec(2);
    Z(ii)=vec(3);
end

tip=surf(X+p2(1), Y+p2(2), Z+p2(3));
set(tip, 'FaceColor', 'k', 'EdgeColor', 'none');

%% add encapsulation tip layer

encapsulation_radius_tip=lead_radius + .2;

[X_encap_tip, Y_encap_tip, Z_encap_tip] = sphere();
X_encap_tip = X_encap_tip * encapsulation_radius_tip;
Y_encap_tip = Y_encap_tip * encapsulation_radius_tip;
Z_encap_tip = Z_encap_tip * encapsulation_radius_tip;
mask_tip = Z_encap_tip >= 0 & Z_encap_tip <= encapsulation_radius_tip;
X_encap_tip = X_encap_tip .* mask_tip;
Y_encap_tip = Y_encap_tip .* mask_tip;
%Z_encap_tip = Z_encap_tip .* mask_tip;
Z_encap_tip = -Z_encap_tip .* mask_tip;
for ii=1:numel(X_encap_tip)
    vec = R * [X_encap_tip(ii), Y_encap_tip(ii), Z_encap_tip(ii)]';
    X_encap_tip(ii) = vec(1);
    Y_encap_tip(ii) = vec(2);
    Z_encap_tip(ii) = vec(3);
end

encap_tip = surf(X_encap_tip + p2(1), Y_encap_tip + p2(2), Z_encap_tip + p2(3));
set(encap_tip, 'FaceColor', encapsulation_color, 'EdgeColor', 'none', 'FaceAlpha', encapsulation_transparency);

end

