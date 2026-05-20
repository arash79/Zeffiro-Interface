% --- Zeffiro documentation header ---
% if isfield(zef,'source_positions_original_field') — If isfield(zef,'source positions original field').
%
% Purpose:
%   If isfield(zef,'source positions original field').
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Zef fields (observed):
%   zef.L (read, write)
%   zef.L_original_field (read, write)
%   zef.n_sources (read)
%   zef.rand_vec_aux (read, write)
%   zef.source_direction_mode (read)
%   zef.source_directions (read, write)
%   zef.source_directions_original_field (read, write)
%   zef.source_interpolation_ind (read, write)
%   zef.source_interpolation_ind_original_field (read, write)
%   zef.source_positions (read, write)
%   zef.source_positions_original_field (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isfield(zef,'source_positions_original_field')` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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

    if ismember(zef.source_direction_mode,2)
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
