function montage3

%   Jordan Bilderbeek July 10 2023

%   Creates an azimuth x elevation subplot to visualize a 3D figure. Used
%   primarily with glass brain DBS/sEEG visualization. 

%% montage3
azimuth=[-90 -180 -270]; %Define azimuth and elevation
elevation=[0 10];
ax1=gca;
f1=get(ax1, 'children');

figure()
for ii=1:length(azimuth)
    for jj=1:length(elevation)
        s((ii-1)*numel(elevation) + jj)=subplot(numel(azimuth), numel(elevation), (ii-1)*numel(elevation) + jj);
        copyobj(f1, s((ii-1)*numel(elevation) + jj));
        view(azimuth(ii), elevation(jj));
        camlight right
    end
end