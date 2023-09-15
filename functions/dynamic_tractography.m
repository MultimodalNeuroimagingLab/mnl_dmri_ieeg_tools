function dynamic_tractography(coord_arr, elec_pos, speed)

%   Jordan Bilderbeek September 6 2023
%
%   Method: Suppose we have multiple 3xN coord arrays (coord_arr) that hold
%   information for different tractography streamlines. This will likely be
%   a downsample (say 1% from all of the given streamlines from a white
%   matter bundle). We may take this from the AFQ 'numfibers' random
%   selection. Given some electrode position (centroid - elec_pos)
%   find the distance to the nearest point on the coord_arr, then bisect
%   the coord_arr into two and find the distance to the endpoints of the
%   streamline. Once we have the distances, lets upsample the streamline 
%   coord_arr so that we can move through it at some speed and time step 
%   (dt_ms). We can make spheres that traverse the tracks based on a
%   latency calculation. 
%
%   Requirements: requires a gifti with track to already be plotted as
%   current figure
%   
%   INPUTS:
%       a) coord_arr - Nx1 cell array where each cell contains a 3xN single
%       of XYZ positions. Can be taken from create_trkstruct and indexed
%       ex coord_arr=fg_fromtrk(n).fibers
%       b) elec_pos - 1x3 double that corresponds to XYZ position of the
%       electrode contact giving stimulation
%       c) speed - estimated transmission speed (in mm/ms -- the same as
%       m/s). Based on a distance calculation in script14_dist_btwn_pairs
%       and latency estimation.
%
%   OUTPUTS: 
%       a) saves a video to the desktop ~/Desktop/dynamic_tractography.mp4
%       displaying the stim pulse moving with a given speed

num_upsample=1000;
% Gather figure limits to display timing tag
xL=xlim;
yL=ylim;
zL=zlim;

euclidean_distances=NaN(length(coord_arr), 2);
dist_2_elec=zeros(length(coord_arr), 1);
bisect_spline=NaN(length(coord_arr), 2, 4, num_upsample); %where NxNx1:3xN is the coords and NxNx4xN is times

for calc_distances=1:length(coord_arr)

        % Perform euclidean distance calculation from the electrode
        % position to every point along the coord_arr. Then find the
        % minimum and the index (to bisect the line). 
        xyz=coord_arr{calc_distances};
        dist=vecnorm(bsxfun(@minus, xyz, elec_pos'));  
        [dist_2_elec(calc_distances), bisect_ind]=min(dist);

        %From the bisect index, then find the distance along the tracks. We
        %also find the inder distance, which is the interval distance
        %between two points (not needed anymore). Will be valuable when we want to figure out
        %how to move spheres along the points. 
        [dist_start_to_bisect, ~]=trk_distance(xyz(1, 1:bisect_ind), xyz(2, 1:bisect_ind), xyz(3, 1:bisect_ind), 0);
        [dist_bisect_to_end, ~]=trk_distance(xyz(1, bisect_ind:end), xyz(2, bisect_ind:end), xyz(3, bisect_ind:end), 0);
       
        % Assign distaces to the euclidean_distances out structure. If the
        % distance from start to bisect is less than 3mm, then there is no
        % reason to visualize that side and we can only do the long side of
        % the bisection. If not NaN, we'll fit a spline and upsample such
        % that we get the same number of samples for each track.  
        
        if dist_start_to_bisect>3
            
            % Where the euclidean distances structure saves BOTH the
            % electrode to bisection point, and then bisect point to the
            % endpoint
            
            euclidean_distances(calc_distances, 1)=dist_start_to_bisect + dist_2_elec(calc_distances);
            
            % Create composite spline that starts at the electrode position,
            % then moves along each side of the bisected track. We dont make
            % the spline if we have a NaN in the euclidean distance (side
            % dependent). Set the spline to be an upsample ~1000 points. 
            
            spline=cscvn([elec_pos', fliplr(xyz(:, 1:bisect_ind))]); %N.B need to go from bisect_ind -> first index
            parameter=linspace(min(spline.breaks), max(spline.breaks), num_upsample); %if we set unit interval will fail
            %parameter=linspace(0, 1, num_upsample); %[0 1] is unit interval parameterization
            bisect_spline(calc_distances, 1, 1:3, :)=ppval(spline, parameter);
        end

            % Reapeat for other bisection, assign spline to Nx2xNxN
        if dist_bisect_to_end>3
            euclidean_distances(calc_distances, 2)=dist_bisect_to_end + dist_2_elec(calc_distances);
            spline=cscvn([elec_pos', xyz(:, bisect_ind:end)]);
            parameter=linspace(min(spline.breaks), max(spline.breaks), num_upsample);
            bisect_spline(calc_distances, 2, 1:3, :)=ppval(spline, parameter);
        end       
end

% Where euclidean_distances/num_upsample is the step size. Multiplying by
% 1/speed gets the number of ms in one step. Once we have the number of ms
% in one step, we can assign times to the spline points. 
ms_step=1/speed * (euclidean_distances/num_upsample);
for numtrks=1:length(ms_step)
    bisect_spline(numtrks, 1, 4, :)=0:ms_step(numtrks, 1):(num_upsample-1)*ms_step(numtrks, 1);
    bisect_spline(numtrks, 2, 4, :)=0:ms_step(numtrks, 2):(num_upsample-1)*ms_step(numtrks, 2);
end

% Squeeze and cat both sides of the bisection
both_bisect_spline=squeeze(cat(1, bisect_spline(:, 1, :, :), bisect_spline(:, 2, :, :))); 

% Permute to arrange dimensions, then reshape
permute_mat=permute(both_bisect_spline, [2 1 3]);
pos_time_mat=reshape(permute_mat, size(permute_mat, 1), [])';

% Sort the rows based on time the points need to be plotted
pos_time_mat_sorted=sortrows(pos_time_mat, 4);

% Remove NaNs due to the bisection being within 3mm of an endpoint
sorted_data=rmmissing(pos_time_mat_sorted);

% Round the sorted time. If we dont round, then all of the points will be
% plotted at different intervals (i.e if something needs to be plotted at
% .3045ms and another at .3046ms we loop through twice -- inneficient and
% causes the appearance to look odd as they dont appear to be moving
% uniformly. round(data, num_after_decimal)
time_sorted=round(sorted_data(:, 4), 1);

currentIndex=1;
hold on;

% Set up the video writer - direct path to desktop, save as MP4. As the
% visualization will take some time -> assuming speed is around 1m/s, we
% set a high frame rate to speed up the movie. 
outputVideo=VideoWriter('~/Desktop/dynamic_tractography.mp4', 'MPEG-4');
outputVideo.FrameRate=90;
open(outputVideo);
while currentIndex <= size(sorted_data, 1)
    
    % Find the rounded times that match, if they do, we plot the scatter at
    % the same time. 
    sameTimeIndices=find(time_sorted == time_sorted(currentIndex));

    % Plot the scatter points, making them yellow, and large. Add text to
    % detail what the timing is. The realtime output will be running as
    % fast as MATLAB can plot the scatters, but the timing update will give
    % the raw time in ms for accuracy. 
    h=scatter3(sorted_data(sameTimeIndices, 1), sorted_data(sameTimeIndices, 2), sorted_data(sameTimeIndices, 3), 200, [1 1 0], 'filled', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1); drawnow;
    htext=text(round(.99*xL(2)), round(.99*yL(2)), round(.99*zL(2)), ['      ' ... 
        num2str(time_sorted(currentIndex)) ' ms'], 'Color', 'blue', 'FontSize', 10, 'HorizontalAlignment', 'left'); drawnow;
    
    frame=getframe(gcf);
    writeVideo(outputVideo, frame);
    
    % Delete and clear the handles for the scatter plot and the text
    % displaying the time. Then update the indexes for the loop. 
    delete(h); clear h; delete(htext), clear htext;
    currentIndex=currentIndex+length(sameTimeIndices);

end

% Get empty frame at the end of the movie, close the video, and save to the
% given path.
frame=getframe(gcf);
writeVideo(outputVideo, frame);
close(outputVideo);
end


