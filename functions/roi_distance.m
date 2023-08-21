function dist = roi_distance(elecxyz, roifile, seg)

%   Jordan Bilderbeek July 24 2023; updated August 3
%
%   roi_distance computes the distance from elecxyz to the nearest vertex
%   of the roifile. We perform a function call to an external triangulation
%   function (intriangulation) to determine whether the electrode xyz is
%   inside of the roi or outside, if outside, we calculate the distance to
%   it. 
%
%   INPUTS:
%       A) elecxyz: is a x3 array of xyz coordinates (for electrode contact
%       centriod)
%       B) roifile: fullpath to ROI. this can be to a custom freesurfer
%       segmentation nifti (where we use the seg tag to get a specific
%       region). this can also be a individual nifti file for one roi
%       C) seg: pulls out a specific region in the fullfile nifti. if seg
%       is string - this assumes we are using one roi in nifti and the name
%       saved in structure will be the passed string
%
%   OUTPUTS
%       A) dist: euclidean distance calculated via l2 norm from elecxyz to
%       nearest ROI vertex, or a specific string if inside of the volume



%% l2norm
function dist=vecl2norm(mat,varargin) %euclidean distance function, can also use vecnorm (tested, same result)
    mat=sum(abs(mat).^2, varargin{:});
    dist=sqrt(mat);
end

nifti=niftiRead(roifile);
if ischar(seg)
    % if seg is a string, we assume that the entire nifti is one
    % segmentation, thus we want nonzero datapoints
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data>0));
elseif length(seg)==1
    % if seg is not a string, we assume that the nifti is composed of
    % multiple segs with different .data pixel values, and pull out a
    % specific value.
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data==seg));
else
    upperbound=max(seg);
    lowerbound=min(seg);
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data > lowerbound & nifti.data < upperbound));
    
end

[xyz] = [rr cc vv ones(size(vv))] * nifti.qto_xyz'; %apply transformation matrix from roi file
roi.coords = xyz(:,1:3);
figure()
h=AFQ_RenderRoi(roi,[0.6824 0.1255 0.0706],'mesh','surface'); 

in=intriangulation(h.Vertices, h.Faces, elecxyz); %call to external triangulation function
if in==1
    dist=0;
elseif in==-1
    dist=NaN; %should never trigger due to number of vertices and faces
else
    elecxyz=elecxyz';
    dist=vecl2norm(bsxfun(@minus, h.Vertices', elecxyz), 1);   %calculate distance via l2 norm if not inside (or unable to triangulate)
    dist=min(dist);
end
close(gcf);






end

