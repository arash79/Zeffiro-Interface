function zef = zef_build_compartment_table(zef)
%ZEF_BUILD_COMPARTMENT_TABLE  Refresh segmentation-tool compartment table data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks zef.compartment_tags in reverse order, collects Segmentation
%   profile parameters marked On, and writes rows into
%   zef.h_compartment_table when that handle is valid. Returns immediately
%   if the table handle is missing or invalid.
%
%   zef = zef_build_compartment_table(zef)
%
%   Input
%     zef - session struct with compartment_tags and parameter_profile.
%
%   Output
%     zef - session after table Data update (aux_field_1 removed).
%
%   See also zef_init_fields_compartment_table, zef_import_segmentation.

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
