function [fg_fromtrk]=create_trkstruct(ni_dwi, tracksin)

%   Jordan Bilderbeek July 20 2023; updated August 7
%
%   create_trkstruct creates a track structure that can be used for
%   plotting via AFQ. we pass in a loaded dwi file, and the header
%   transforms a loaded .trk file into the corresponding space. we iterate
%   over the .trk and add the neccesary components to the structure. 
%   
%   INPUTS:
%       a) ni_dwi - loaded struct of a nifti diffusion weighted image (output
%       from niftiRead)
%       b) tracksin - a cell array in which each cell contains the fullpath to
%       a .trk file from DSI studio output
%
%   OUTPUTS:
%       a) fg_fromtrk - struct that contains all the loaded tracks in the
%       correct space, along with other information (name, fibers, colors) that
%       correspond to each track



%% create_trkstruct
fg_fromtrk = [];
for ss = 1:length(tracksin)
    trk_file = tracksin{ss};
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file); %read trk file
        
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii); %apply transformation fro ni_dwi
        end

        trk_name=regexp(trk_file, '/', 'split');
        fg_fromtrk(ss).name = regexprep(trk_name{end}, '_R.trk', '');
        fg_fromtrk(ss).name = regexprep(fg_fromtrk(ss).name, '_L.trk', ''); %alter the name s.t. we dont have any _L or _R 
        fg_fromtrk(ss).colorRgb = [20 90 200];
        fg_fromtrk(ss).thickness = 0.5;
        fg_fromtrk(ss).visible = 1;
        fg_fromtrk(ss).seeds = [];
        fg_fromtrk(ss).seedRadius = 0;
        fg_fromtrk(ss).fibers = cell(length(tracks),1);
        for kk = 1:length(tracks)
            this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
            fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:); %create individual streamlines
            clear this_strm
        end
        
        clear header tracks
    else
        warningMessage = sprintf('Warning: Track file does not exist:\n%s', trk_file);
    return;
    end
end



end

