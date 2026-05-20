function zef = zef_build_compartment_table(zef)
% --- Zeffiro documentation header ---
% zef_build_compartment_table — Zef build compartment table.
%
% Purpose:
%   Zef build compartment table.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.aux_field_1 (read, write)
%   zef.compartment_table_size (read)
%   zef.compartment_tags (read, write)
%   zef.h_compartment_table (read)
%   zef.parameter_profile (read)
%
% Calls (project):
%   zef_build_compartment_table
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_build_compartment_table(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

% CRITICAL: Check if UI handle exists before accessing it
if not(isfield(zef,'h_compartment_table')) || not(isvalid(zef.h_compartment_table))
    return;
end

% Ensure compartment_tags exists
if not(isfield(zef,'compartment_tags')) || not(iscell(zef.compartment_tags))
    zef.compartment_tags = {};
end

zef.aux_field_1 = cell(0);

zef_i = 0;

for zef_j = length(zef.compartment_tags) : -1 : 1

    zef_i = zef_i + 1;

    % Only call zef_init_fields_compartment_table if handle still exists
    if isfield(zef,'h_compartment_table') && isvalid(zef.h_compartment_table)
        zef_init_fields_compartment_table;
    end

    zef_n = 0;
    for zef_k =  1  : size(zef.parameter_profile,1)
        if isequal(zef.parameter_profile{zef_k,8},'Segmentation') && isequal(zef.parameter_profile{zef_k,6},'On') && isequal(zef.parameter_profile{zef_k,7},'On')
            zef_n = zef_n + 1;
            if isfield(zef,'h_compartment_table') && isvalid(zef.h_compartment_table)
                zef.h_compartment_table.ColumnName{zef_n+zef.compartment_table_size} = zef.parameter_profile{zef_k,1};
            end
            if isequal(zef.parameter_profile{zef_k,3},'Scalar')
                zef.aux_field_1{zef_i,zef_n+zef.compartment_table_size} = num2str(eval(['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_k,2}]));
            elseif isequal(zef.parameter_profile{zef_k,3},'String')
                zef.aux_field_1{zef_i,zef_n + zef.compartment_table_size} = (eval(['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_k,2}]));
            end
        end
    end

end

if isfield(zef,'h_compartment_table') && isvalid(zef.h_compartment_table)
    % Temporarily disable callbacks to prevent recursion during programmatic updates
    original_callback = zef.h_compartment_table.CellEditCallback;
    zef.h_compartment_table.CellEditCallback = '';
    zef.h_compartment_table.Data = zef.aux_field_1;
    zef.h_compartment_table.CellEditCallback = original_callback;
end
zef = rmfield(zef,'aux_field_1');
% CRITICAL FIX: Skip zef_update here - it can hang during project load on large projects.
% The table data is already set above, and zef_update will be called when user interacts with UI.
% During load, calling zef_update can cause infinite loops or hangs.

if nargout == 0
    assignin('base','zef',zef);
end

end
