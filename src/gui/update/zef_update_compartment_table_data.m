function zef = zef_update_compartment_table_data(zef)
% --- Zeffiro documentation header ---
% zef_update_compartment_table_data — Syncs GUI control values into `zef` for compartment_table_data.
%
% Purpose:
%   Syncs GUI control values into `zef` for compartment_table_data.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.aux_field_1 (read)
%   zef.compartment_table_size (read)
%   zef.compartment_tags (read, write)
%   zef.h_compartment_table (read)
%   zef.parameter_profile (read)
%
% Calls (project):
%   zef_update_compartment_table_data
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_update_compartment_table_data(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

% CRITICAL: Check if required UI handle exists before accessing it
if not(isfield(zef,'h_compartment_table')) || not(isvalid(zef.h_compartment_table))
    return;
end

% Ensure compartment_tags exists and is a cell array
if not(isfield(zef,'compartment_tags')) || not(iscell(zef.compartment_tags))
    return;
end

zef.compartment_tags = fliplr(zef.compartment_tags);

for zef_i = 1 : length(zef.compartment_tags) 

    zef_j = zef_i;

    zef_init_fields_compartment_table

    zef_n = 0;
    for zef_k =  1 : size(zef.parameter_profile,1)
        if isequal(zef.parameter_profile{zef_k,8},'Segmentation') && isequal(zef.parameter_profile{zef_k,6},'On') && isequal(zef.parameter_profile{zef_k,7},'On')
            zef_n = zef_n + 1;
            zef.h_compartment_table.ColumnName{zef_n+zef.compartment_table_size} = zef.parameter_profile{zef_k,1};
            if isequal(zef.parameter_profile{zef_k,3},'Scalar')
                zef.aux_field_1{zef_i,zef_n+zef.compartment_table_size} = num2str(eval(['zef.' zef.compartment_tags{zef_i} '_' zef.parameter_profile{zef_k,2}]));
            elseif isequal(zef.parameter_profile{zef_k,3},'String')
                zef.aux_field_1{zef_i,zef_n + zef.compartment_table_size} = (eval(['zef.' zef.compartment_tags{zef_i} '_' zef.parameter_profile{zef_k,2} ]));
            end
        end
    end

end

% Ensure handle still exists (might have been deleted during execution)
if isfield(zef,'h_compartment_table') && isvalid(zef.h_compartment_table)
    % Temporarily disable callbacks to prevent recursion during programmatic updates
    original_callback = zef.h_compartment_table.CellEditCallback;
    zef.h_compartment_table.CellEditCallback = '';
    zef.h_compartment_table.Data = zef.aux_field_1;
    zef.h_compartment_table.CellEditCallback = original_callback;

    if size(zef.h_compartment_table.Data,2) > length(zef.h_compartment_table.ColumnEditable)
        missing_entries = (size(zef.h_compartment_table.Data,2) - length(zef.h_compartment_table.ColumnEditable));
        zef.h_compartment_table.ColumnEditable = [zef.h_compartment_table.ColumnEditable repmat(true,1,missing_entries)];
    end

    if size(zef.h_compartment_table.Data,2) > length(zef.h_compartment_table.ColumnWidth)
        missing_entries = (size(zef.h_compartment_table.Data,2) - length(zef.h_compartment_table.ColumnWidth));
        zef.h_compartment_table.ColumnWidth = [zef.h_compartment_table.ColumnWidth repmat({'fit'},1,missing_entries)];
    end
end

zef.compartment_tags = fliplr(zef.compartment_tags);

if nargout == 0
    assignin('base','zef',zef);
end
