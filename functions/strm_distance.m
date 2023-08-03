function fg_fromtrk=strm_distance(fg_fromtrk, roi)

%   Jordan Bilderbeek July 18 2023
%
%   Search through each streamline within each fiber track and perform
%   euclidean distance with roi (electrode position of interest). Save in
%   fg_fromtrk struct. 
%
%   INPUTS: 
%       a) fg_fromtrk - track structure generated with all tracks and
%       streamlines. Can index via fg_fromtrk(track).fibers{strmln} 
%       which will give 3xN array of streamline points for the specific
%       fiber track. 
%       b) roi - typically a 1x3 xyz of electrode centroid. Can be any
%       other region of interest. 
%
%   OUTPUTS: 
%       a) fg_fromtrk - .distance is added to the structures with the
%       euclidean distance for every track and each individual streamline
%       point within track. 



%% Calculate euclidean distance
roi=roi';
for ii=1:length(fg_fromtrk) %Calculate distance for all
    for jj=1:length(fg_fromtrk(ii).fibers)
        [~,M]=size(fg_fromtrk(ii).fibers{jj});
        dist=vecnorm(bsxfun(@minus, fg_fromtrk(ii).fibers{jj}, roi));  
        fg_fromtrk(ii).distance{jj}=reshape(dist, M, []);
        fg_fromtrk(ii).mindist{jj}=min(dist);
    end
end


end

