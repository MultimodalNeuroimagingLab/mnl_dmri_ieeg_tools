function renderROI(nifti, seg)
%   Jordan Bilderbeek July 24 2023
%
%   Renders a ROI given a nifti loaded structure. Seg is used to determine 
%   which freesurfer segmentation we want to use. As we used
%   segmentation2qsiprep the seg values are atypical from the standard
%   freesurfer. 
%   

%% renderROI

[rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data==seg));
[xyz] = [rr cc vv ones(size(vv))] * nifti.qto_xyz';
roi.coords = xyz(:,1:3);
h=AFQ_RenderRoi(roi,[0.6824 0.1255 0.0706],'mesh','surface');
h.FaceAlpha=.5;


end

