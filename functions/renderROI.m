function h=renderROI(nifti, color, seg)
%   Jordan Bilderbeek July 24 2023
%
%   Renders a ROI  given a nifti loaded structure. We find coordinates
%   based on pix values greater than zero, then call AFQ_RenderRoi. If we
%   have 3 args, find the segmentation value and use this for coordinates. 
%   
%   INPUTS: 
%       a) nifti: loaded nifti image (either whole segmentation or
%       parcellated)
%       b) color: color of roi render
%       c) seg: optional segmentation to select certain roi in multi-seg
%       nifti volume
%
%   OUTPUTS: 
%       a) h: output structure of AFQ_renderRoi (plotted struct) with
%       vertices and faces


%% renderROI

if exist(seg, 'var')
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data==seg));
else
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data>0));
end

[xyz] = [rr cc vv ones(size(vv))] * nifti.qto_xyz';
roi.coords = xyz(:,1:3);
h=AFQ_RenderRoi(roi,color,'mesh','surface');



end

