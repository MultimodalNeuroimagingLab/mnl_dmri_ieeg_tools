function fg_fromtrk=euclidean_distance(fg_fromtrk, roi, varargin)

%   Jordan Bilderbeek July 18 2023

%   Search through each streamline within each fiber track and perform
%   euclidean distance with roi (electrode position of interest). Save in
%   fg_fromtrk struct. 

%   Input: 
%       a) fg_fromtrk - track structure generated with all tracks and
%       streamlines. Can index via fg_fromtrk(track).fibers{strmln} 
%       which will give 3xN array of streamline points for the specific
%       fiber track. 
%       b) roi - typically a 1x3 xyz of electrode centroid. Can be any
%       other region of interest. 
%       c) varargin - can add 'angle' as a tag - nargin will recognize and
%       compute the angle between electrode and streamline. 

%       Example use: euclidean_distance(fg_fromtrk, roi, 'Fornix', 'Cingulum_Frontal_Parietal').

%   Output: 
%       a) fg_fromtrk - .distance is added to the structures with the
%       euclidean distance for every track and each individual streamline
%       point within track. 


%% l2norm
function dist=vecl2norm(mat,varargin)
    mat=sum(abs(mat).^2, varargin{:});
    dist=sqrt(mat);
end

%% Calculate euclidean distance via l2norm
roi=roi';
for ii=1:length(fg_fromtrk) %Calculate distance for all
    for jj=1:length(fg_fromtrk(ii).fibers)
        [~,M]=size(fg_fromtrk(ii).fibers{jj});
        dist=vecl2norm(bsxfun(@minus, fg_fromtrk(ii).fibers{jj}, roi), 1);  
        fg_fromtrk(ii).distance{jj}=reshape(dist, M, []);
    end
end

%% Calculate angle
if nargin > 2 %can add 'angle' tag in function call to compute the angle as well
    pnorm=roi/norm(roi); 
    for ii=1:length(fg_fromtrk) 
        for jj=1:length(fg_fromtrk(ii).fibers) %a vectorized approach to calculating angle instead of iterating through each 3xN array
            [~,M]=size(fg_fromtrk(ii).fibers{jj});
            vdiff=fg_fromtrk(ii).fibers{jj}-roi; % Create vector
            vdiffnorm=sqrt(sum(vdiff.^2, 1)); %Compute norm of vector
            vdiffnorm=bsxfun(@rdivide, vdiff, vdiffnorm); %Normalize all vectors
            dot=sum(bsxfun(@times, pnorm, vdiffnorm), 1);
            %fg_fromtrk(ii).angle{jj}=reshape(acosd(dot), M, []);
            fg_fromtrk(ii).angle{jj}=reshape(acos(dot), M, []);
        end
    end
end

end

