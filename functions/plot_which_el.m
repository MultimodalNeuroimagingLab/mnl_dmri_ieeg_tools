function [coords, tag]=plot_which_el(elStruct)

%   Jordan Bilderbeek July 21 2023



disp('Which sEEG lead would you like to plot? Your options are:')
for ii=1:length(elStruct)
    disp(elStruct(ii).name);
end
out=input('', "s");

for ii=1:length(elStruct)
    name=elStruct(ii).name;
    if name==out
        coords=elStruct(ii).positions;
    end
end

side=mean(coords(:,1));
if side < 0
    tag='L';
else
    tag='R';
end

end

