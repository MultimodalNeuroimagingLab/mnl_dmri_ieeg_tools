function [fg_fromtrk]=create_trkstruct(ni_dwi, tracksin)

fg_fromtrk = [];
for ss = 1:length(tracksin)
    trk_file = tracksin{ss};
    if exist(trk_file, 'file')

        [header,tracks] = trk_read(trk_file);
        
        header.vox_to_ras = ni_dwi.qto_xyz;
        transf_mat = header.vox_to_ras;
        for ii = 1:3
            transf_mat(:,ii) = transf_mat(:, ii)./header.voxel_size(ii);
        end

        % Create FG structure that can be visualized with AFQ tools
        % We apply a transofrmatrion matrix to make sure the tracks are in the
        % original dMRI space
        trk_name=regexp(trk_file, '/', 'split');
        fg_fromtrk(ss).name = regexprep(trk_name{end}, '_R.trk', '');
        fg_fromtrk(ss).name = regexprep(fg_fromtrk(ss).name, '_L.trk', '');
        fg_fromtrk(ss).colorRgb = [20 90 200];
        fg_fromtrk(ss).thickness = 0.5;
        fg_fromtrk(ss).visible = 1;
        fg_fromtrk(ss).seeds = [];
        fg_fromtrk(ss).seedRadius = 0;
        fg_fromtrk(ss).fibers = cell(length(tracks),1);
        for kk = 1:length(tracks)
            this_strm = transf_mat*[tracks(kk).matrix ones(length(tracks(kk).matrix),1)]';
            fg_fromtrk(ss).fibers{kk} = this_strm(1:3,:);
            clear this_strm
        end
        
        clear header tracks
    else
        warningMessage = sprintf('Warning: Track file does not exist:\n%s', trk_file);
    return;
    end
end



end

