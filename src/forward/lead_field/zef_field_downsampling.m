%ZEF_FIELD_DOWNSAMPLING  Mesh-tool "Resample field": subsample source columns of zef.L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Bound to h_field_downsampling. Caches the full field in
%   *_original_field on first run (or restores from that cache). If
%   zef.n_sources is smaller than the number of source positions, draws a
%   random subset: Cartesian/normal (direction_mode 2) keeps 3 L columns per
%   source; basis mode (3) keeps one column per source. Then
%   zef_source_interpolation. No-op when n_sources is not smaller.
%
%   See also zef_source_interpolation, zef_mesh_tool.

if isfield(zef,'source_positions_original_field')
    if isempty(zef.source_positions_original_field)

        zef.source_positions_original_field = zef.source_positions;
        zef.source_directions_original_field = zef.source_directions;
        zef.L_original_field = zef.L;
        zef.source_interpolation_ind_original_field = zef.source_interpolation_ind;

    else

        zef.source_positions = zef.source_positions_original_field;
        zef.source_directions = zef.source_directions_original_field;
        zef.L = zef.L_original_field;
        zef.source_interpolation_ind = zef.source_interpolation_ind_original_field;
    end

else

    zef.source_positions_original_field = zef.source_positions;
    zef.source_directions_original_field = zef.source_directions;
    zef.L_original_field = zef.L;
    zef.source_interpolation_ind_original_field = zef.source_interpolation_ind;

end

if zef.n_sources < size(zef.source_positions,1)

    zef.rand_vec_aux = randperm(size(zef.source_positions,1));
    zef.rand_vec_aux = zef.rand_vec_aux(1:zef.n_sources);
    zef.source_positions = zef.source_positions(zef.rand_vec_aux,:);

    if ismember(zef.source_direction_mode,[1 2])
        zef.rand_vec_aux = 3*(zef.rand_vec_aux(:)'-1);
        zef.rand_vec_aux = [zef.rand_vec_aux + 1; zef.rand_vec_aux + 2; zef.rand_vec_aux + 3];
        zef.rand_vec_aux = zef.rand_vec_aux(:);
        zef.L = zef.L(:,zef.rand_vec_aux);
    elseif ismember(zef.source_direction_mode,[3])
        zef.L = zef.L(:,zef.rand_vec_aux);
    end
    if not(isempty(zef.source_directions))
        zef.source_directions = zef.source_directions(zef.rand_vec_aux,:);
    end

    zef_source_interpolation;

    zef = rmfield(zef,'rand_vec_aux');

end
