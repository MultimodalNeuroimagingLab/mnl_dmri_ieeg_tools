function dynamic_tractography(coord_arr, elec_pos, speed, dt_ms)

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
%   INPUTS:
%       a) coord_arr
%       b) elec_pos
%       c) speed (in mm/ms -- the same as m/s)
%       d) dt_ms (time step for visualization)

euclidean_distances=zeros(2, length(coord_arr));
dist_2_elec=zeros(1, length(coord_arr));
dist_inter_bisect_to_start=cell(1, length(coord_arr));
dist_inter_bisect_to_end=cell(1, length(coord_arr));

for calc_distances=1:length(coord_arr)

        % Perform euclidean distance calculation from the electrode
        % position to every point along the coord_arr. Then find the
        % minimum and the index (to bisect the line). 
        xyz=coord_arr{calc_distances};
        dist=vecnorm(bsxfun(@minus, xyz', elec_pos'));  
        [dist_2_elec(calc_distances), bisect_ind]=min(dist);

        %From the bisect index, then find the distance along the tracks. We
        %also find the inder distance, which is the interval distance
        %between two points. Will be valuable when we want to figure out
        %how to move spheres along the points. 
        [dist_start_to_bisect, dist_inter_bisect_to_start{calc_distances}]=trk_distance(xyz(1:bisect_ind, 1), xyz(1:bisect_ind, 2), xyz(1:bisect_ind, 3), 0);
        [dist_bisect_to_end, dist_inter_bisect_to_end{calc_distances}]=trk_distance(xyz(bisect_ind:end, 1), xyz(bisect_ind:end, 2), xyz(bisect_ind:end, 3), 0);
       
        % Assign distaces to the euclidean_distances out structure. If the
        % distance from start to bisect is less than 3mm, then there is no
        % reason to visualize that side and we can only do the long side of
        % the bisection. 

        if dist_start_to_bisect<3
            euclidean_distances(1, calc_distances)=NaN;
        else
            euclidean_distances(1, calc_distances)=dist_start_to_bisect + dist_2_elec(calc_distances);
        end

        if dist_bisect_to_end<3
            euclidean_distances(2, calc_distances)=NaN;
        else
            euclidean_distances(2, calc_distances)=dist_bisect_to_end + dist_2_elec(calc_distances);
        end
end

% Calculate the total distance for each streamline segment
    total_distances = cellfun(@(d1, d2) sum([d1, d2]), dist_inter_bisect_to_start, dist_inter_bisect_to_end);

    % Calculate the time required to traverse each segment at the given speed
    traverse_times = total_distances / speed;

    % Calculate the number of steps for each segment based on dt_ms
    num_steps = round(traverse_times / dt_ms);

    % Initialize sphere positions for each segment
    sphere_positions = cell(size(coord_arr));

    % Calculate the starting time offset for each segment based on dist_2_elec
    time_offsets = dist_2_elec / speed;

    % Initialize a figure for visualization
    figure;
    hold on;
    grid on;
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');

    % Main simulation loop
    for step = 1:max(num_steps)
        for calc_distances = 1:length(coord_arr)
            if step > time_offsets(calc_distances) / dt_ms && step <= num_steps(calc_distances)
                % Calculate the interpolation factor for the current step
                interp_factor_forward = (step - time_offsets(calc_distances) / dt_ms) / num_steps(calc_distances);
                interp_factor_backward = 1 - interp_factor_forward;

                % Check if euclidean_distances is NaN for position 1 or 2
                if isnan(euclidean_distances(1, calc_distances))
                    current_position_forward = [];
                else
                    % Interpolate the sphere position along the segment in the forward direction
                    xyz = coord_arr{calc_distances};
                    current_position_forward = interp1(linspace(0, 1, size(xyz, 1)), xyz, interp_factor_forward);
                end

                if isnan(euclidean_distances(2, calc_distances))
                    current_position_backward = [];
                else
                    % Interpolate the sphere position along the segment in the backward direction
                    xyz = coord_arr{calc_distances};
                    current_position_backward = interp1(linspace(0, 1, size(xyz, 1)), xyz, interp_factor_backward);
                end

                % Update and plot the sphere positions
                sphere_positions{calc_distances} = [current_position_forward; current_position_backward];

                % Plot the spheres (customize the appearance as needed)
                if ~isempty(current_position_forward)
                    plot3(current_position_forward(1), current_position_forward(2), current_position_forward(3), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
                end
                if ~isempty(current_position_backward)
                    plot3(current_position_backward(1), current_position_backward(2), current_position_backward(3), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
                end
            end
        end

        % Pause for visualization (adjust as needed)
        pause(dt_ms / 1000);
    end


