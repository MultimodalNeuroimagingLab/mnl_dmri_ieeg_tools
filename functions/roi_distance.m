function dist = roi_distance(elecxyz, roifile, seg)

%   Jordan Bilderbeek July 24 2023



%% l2norm
function dist=vecl2norm(mat,varargin)
    mat=sum(abs(mat).^2, varargin{:});
    dist=sqrt(mat);
end

nifti=niftiRead(roifile);
[rr,cc,vv] = ind2sub(size(nifti.data),find(nifti.data==seg));
[xyz] = [rr cc vv ones(size(vv))] * nifti.qto_xyz';
roi.coords = xyz(:,1:3);
figure()
h=AFQ_RenderRoi(roi,[0.6824 0.1255 0.0706],'mesh','surface'); 

in=intriangulation(h.Vertices, h.Faces, elecxyz);
if in==1
    dist=['Electrode inside qsi-freesurfer vol: ' num2str(seg)];
elseif in==-1
    dist='Unable to triangulate position';
else
    elecxyz=elecxyz';
    dist=vecl2norm(bsxfun(@minus, h.Vertices', elecxyz), 1);  
    dist=min(dist);
end
close(gcf);





end

