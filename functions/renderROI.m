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

if nargin>2
    if length(seg) > 1 %assumes that we have a spread of seg values, select all of them between
        upperbound=max(seg);
        lowerbound=min(seg);
        [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data > lowerbound & nifti.data < upperbound));
    else        
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data==seg)); %assumes we have one seg value, pull it out in nifti.data
    end
else
    [rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data>0)); %assume we have no seg, thus take all positive values
end

[xyz] = [rr cc vv ones(size(vv))] * nifti.qto_xyz'; %multiply coordinates by transformation matrix (q to xyz)
roi.coords = xyz(:,1:3);
h=AFQ_RenderRoi(roi,color,'mesh','surface'); %call AFQ plotter



end

