function fib = trk_concat(trk_struct, elec, varargin)

    % Jordan Bilderbeek September 8 2023
    
    % METHOD: Given a trk_struct, from output from create_trkstruct,
    % concatenate multiple fibers together. The first points in the fiber
    % structure will be those closest to elec, a 1x3 array of XYZ
    % positions. We will then move to the end of the first fiber, and at
    % the endpoints, find the closest point to the next fiber, and then
    % concat them together. Because each tracks have different numbers of
    % streamlines, we first find those with the minimum, and use that
    % number for the rest of the tracks -- will be a random selection of
    % those with extras. 
    %
    % REQUIREMENTS: trk_struct must be created using create_trkstruct
    % function, which houses all DSI studio .trk files. Vararg is in order
    % of concatenation. 
    %
    % INPUTS:
    %       a) trk_struct - output from create_trkstruct; structure that
    %       houses all .trk information and has .fibers (cell of 3xN arrays
    %       with xyz positions for each streamline)
    %       b) elec - 1x3 array of XYZ positions. Elec is used as a point
    %       marker. If your first track to concatenate is the fornix, elec
    %       will find which way the fornix 3xN array should be oriented
    %       (determine a flip). We then go from start -> endpoint -> newtrk
    %       start (closest side to endpoint) -> endpoint -> newtrk start
    %       (closest side to endpoint)
    %       c) varargin - each cell input has a list of tracks you want to
    %       concatenate. They will be concatenated sequentially, but the
    %       first trk may be flipped to give you the start closest to the
    %       electrode position (ideal stim location). 
    %
    % OUTPUTS:
    %       a) fib- array of cells that have 3xN coordinates, which can
    %       then be input into the dynamic tractography function. 
    %
    % EXAMPLE USAGE: 
    % 
    % Concatenate two fibers, starting from the side of the fornix that is
    % closest to the elec position:
    % fib=trk_concat(trk_struct, elec, 'Fornix','Cingulum_Parolfactory')
    % 
    % Concatenate three fibers, starting on the fornix closest to elec 
    % position: 
    % fib=trk_concat(trk_struct, elec, 'Fornix', 'Cingulum_Parolfactory',
    % 'Cingulum_Frontal_Parietal')
 
    %% sanity check
    % Ensure that more than 1 tracks are incorporated. 
    if length(varargin)<2
        disp('Must include multiple tracks to concatenate');
        return
    end
    
    %% trk_concat
    
    % Determine how manys streamlines we have in each trk structure. Once
    % we find the track with the least streamlines, take that number as a
    % random subset out of the other tracks. 
    namearr={trk_struct.name};
    numfibers=zeros(1, length(varargin));
    trk_struct_ind=zeros(1, length(varargin));
    for ii=1:length(varargin)
        [~, trk_struct_ind(ii)]=max(strcmp(namearr, varargin{ii}));
        numfibers(ii)=length(trk_struct(trk_struct_ind(ii)).fibers);
    end
     
    % Pull out the shortest number of streamlines and eliminate it from the
    % numfibers arr. 
    [minlength, ind]=min(numfibers);
    fib=cell(1, length(trk_struct_ind));
    fib{ind}=trk_struct(trk_struct_ind(ind)).fibers;
    
    % Reformat the numfibers and trk_struct_ind by getting rid of the
    % shortest fiber. Save the original as concat_ind.
    concat_ind=trk_struct_ind;
    numfibers(ind)=NaN;
    trk_struct_ind(ind)=NaN;
    
    % Shorten the other tracks such that they have the same number of
    % streamlines and assign them to the fib variable. Use fibassignment to
    % get the correct ind based on the for loop. 
    fibassignment=find(concat_ind==trk_struct_ind);
    for ii=1:length(trk_struct_ind)-1
        random_indices=randperm(numfibers(fibassignment(ii)));
        fibers=trk_struct(trk_struct_ind(fibassignment(ii))).fibers;
        fib{fibassignment(ii)}=fibers(random_indices(1:minlength));
    end

    % Now, lets find the closes point to the electrode on the first
    % streamline. Then we need to reorder the streamlines if they are
    % flipped. We can then concatenate. 
    concat_fib=cell(1, length(fib{1}));
    for ii=1:length(fib{1})
        dist=vecnorm(bsxfun(@minus, fib{1}{ii}, elec'));  
        [~, closestpt]=min(dist);
        numpt=length(dist);
        
        if closestpt > numpt/2
            fib{1}{ii}=fliplr(fib{1}{ii});
        end  
        
        concat_fib{ii}=[fib{1}{ii}];
    end
    
    % We perform a similar procedure than before, now we loop through the
    % other tracks and instead we find the endpoint of the previous to do
    % the distance to. 
    
    for ii=2:length(fib)
        for jj=1:length(fib{ii})
            
            endval=concat_fib{jj}(:,end);
            dist=vecnorm(bsxfun(@minus, fib{ii}{jj}, endval));  
            
            if min(dist) > 40 % if the distance from an endpoint to a new fiber is greater than 20mm we assume that the streamline is not coherent
                concat_fib{jj}=[];
                continue
            end
            
            [~, closestpt]=min(dist);
            numpt=length(dist);
        
            if closestpt > numpt/2
                fib{ii}{jj}=fliplr(fib{ii}{jj});
            end  
        
        concat_fib{jj}=[concat_fib{jj}, fib{ii}{jj}];
        end
    end
        
fib=concat_fib;
end

