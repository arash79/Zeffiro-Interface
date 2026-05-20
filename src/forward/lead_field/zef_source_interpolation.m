
%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_source_interpolation(zef)
% --- Zeffiro documentation header ---
% zef_source_interpolation — Zef source interpolation.
%
% Purpose:
%   Zef source interpolation.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.L (read, write)
%   zef.active_compartment_ind (read)
%   zef.compartment_tags (read)
%   zef.location_unit_current (read)
%   zef.nodes (read)
%   zef.reuna_p (read)
%   zef.reuna_t (read)
%   zef.source_directions (read, write)
%   zef.source_interpolation_ind (read, write)
%   zef.source_positions (read, write)
%   zef.tetra (read)
%
% Calls (project):
%   zef_source_interpolation
%   zef_waitbar
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%   - waitbar progress UI
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_source_interpolation(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

if eval('isequal(size(zef.L,2),size(zef.source_directions,1))')
    eval('zef.source_directions=zef.source_directions(find(not(isnan(sum(abs(zef.L),1)))),:);');
elseif eval('isequal(size(zef.L,2),3*size(zef.source_directions,1))')
    eval('zef.source_directions=zef.source_directions(find(not(isnan(sum(abs(zef.L(:,1:3:end)),1)))),:);');
end
if eval('isequal(size(zef.L,2),size(zef.source_positions,1))')
    eval('zef.source_positions=zef.source_positions(find(not(isnan(sum(abs(zef.L),1)))),:);');
    eval('zef.L=zef.L(:,find(not(isnan(sum(abs(zef.L),1)))))');
elseif eval('isequal(size(zef.L,2),3*size(zef.source_positions,1))')
    eval('zef.source_positions=zef.source_positions(find(not(isnan(sum(abs(zef.L(:,1:3:end)),1)))),:);');
    eval('zef.L=zef.L(:,find(not(isnan(sum(abs(zef.L),1)))));');
end

source_interpolation_ind = [];
active_compartment_ind = eval('zef.active_compartment_ind');
source_positions = eval('zef.source_positions');
nodes = eval('zef.nodes');
tetra = eval('zef.tetra');

if not(isempty(active_compartment_ind)) && not(isempty(source_positions)) && not(isempty(nodes)) && not(isempty(tetra))

    h = zef_waitbar(0,1,['Interpolation 1.']);

    % Ensure waitbar is closed on normal exit or error; prevents stalls/crashes
    cleanupfn = @(x) safe_close_waitbar(x);
    cleanupobj = onCleanup(@() cleanupfn(h));

    if eval('zef.location_unit_current') == 2
        source_positions = 10*source_positions;
    end

    if eval('zef.location_unit_current') == 3
        zef.source_positions = 1000*source_positions;
    end

    [center_points I center_points_ind] = unique(tetra(active_compartment_ind,:));
    source_interpolation_ind{1} = zeros(length(center_points),1);
    source_interpolation_aux = source_interpolation_ind{1};
    center_points = nodes(center_points,:);

    MdlKDT = KDTreeSearcher(source_positions);
    source_interpolation_ind{1} = knnsearch(MdlKDT,center_points);
    source_interpolation_ind{1} = reshape(source_interpolation_ind{1}(center_points_ind), length(active_compartment_ind), 4);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i = 0;
    length_reuna = 0;
    sigma_vec = [];
    priority_vec = [];
    visible_vec = [];
    color_cell = cell(0);
    aux_active_compartment_ind = [];
    aux_dir_mode = [];
    compartment_tags = eval('zef.compartment_tags');
    for k = 1 : length(compartment_tags)

        var_0 = ['zef.' compartment_tags{k} '_on'];
        var_1 = ['zef.' compartment_tags{k} '_sigma'];
        var_2 = ['zef.' compartment_tags{k} '_priority'];
        var_3 = ['zef.' compartment_tags{k} '_visible'];
        color_str = eval(['zef.' compartment_tags{k} '_color']);

        on_val = eval(var_0);
        sigma_val = eval(var_1);
        priority_val = eval(var_2);
        visible_val = eval(var_3);
        if on_val
            i = i + 1;
            sigma_vec(i,1) = sigma_val;
            priority_vec(i,1) = priority_val;
            color_cell{i} = color_str;
            visible_vec(i,1) = i*visible_val;
            if eval(['zef.' compartment_tags{k} '_sources'])>0
                aux_active_compartment_ind = [aux_active_compartment_ind i];
            end

        end
    end

    source_positions_aux = source_positions;

    for ab_ind = 1 : length(aux_active_compartment_ind)

        zef_waitbar((ab_ind+1),(length(aux_active_compartment_ind)+2),h,['Interpolation 2: ' num2str(ab_ind) '/' num2str(length(aux_active_compartment_ind)) '.' ]);

        aux_point_ind = unique(gather(source_interpolation_ind{1}));
        source_positions = source_positions_aux(aux_point_ind,:);

        s_ind_1{ab_ind} = aux_point_ind;

        center_points = eval(['zef.reuna_p{' int2str(aux_active_compartment_ind(ab_ind)) '}']);

        MdlKDT = KDTreeSearcher(source_positions);
        source_interpolation_aux = knnsearch(MdlKDT,center_points);

        source_interpolation_ind{2}{ab_ind} = (s_ind_1{ab_ind}(source_interpolation_aux));

        triangles = eval(['zef.reuna_t{' int2str(aux_active_compartment_ind(ab_ind)) '}']);
        source_interpolation_ind{2}{ab_ind} = source_interpolation_ind{2}{ab_ind}(triangles);

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    zef_waitbar(1,1,h,['Interpolation 3.']);

    aux_p = [];
    aux_t = [];

    for ab_ind = 1 : length(aux_active_compartment_ind)

        aux_t = [aux_t ; size(aux_p,1) + eval(['zef.reuna_t{' int2str(aux_active_compartment_ind(ab_ind)) '}'])];
        aux_p = [aux_p ; eval(['zef.reuna_p{' int2str(aux_active_compartment_ind(ab_ind)) '}'])];

    end

    center_points = (1/3)*(aux_p(aux_t(:,1),:) + aux_p(aux_t(:,2),:) + aux_p(aux_t(:,3),:));

    MdlKDT = KDTreeSearcher(center_points);
    source_interpolation_ind{3} = knnsearch(MdlKDT,source_positions);

    zef.source_interpolation_ind = source_interpolation_ind;

    if nargout == 0
        assignin('base','zef', zef);
    end

end

end

function safe_close_waitbar(h)
% Safely close waitbar figure; prevents stalls/crashes from invalid handles.
    try
        if ~isempty(h) && isvalid(h)
            % Disable callbacks before deletion to avoid callback recursion
            % on rapidly opening/closing waitbars in long pipelines.
            h.CloseRequestFcn = '';
            h.DeleteFcn = '';
            delete(h);
        end
    catch
        % Ignore close errors
    end
end
