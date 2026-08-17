function zef = zef_update_compartment_table_data(zef)
%ZEF_UPDATE_COMPARTMENT_TABLE_DATA  Rebuild Segmentation-tool compartment UITable Data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Called from zef_update after table edits. Flips
%   zef.compartment_tags left-right so row 1 matches the on-screen
%   order, then for each tag runs the script
%   zef_init_fields_compartment_table (needs workspace zef_i, zef_j,
%   zef.aux_field_1) and appends enabled Segmentation parameter-profile
%   columns. Writes zef.h_compartment_table.Data with CellEditCallback
%   temporarily cleared. Flips tags back. nargout==0 → assignin base.
%
%   Returns immediately if h_compartment_table is missing/invalid.
%
%   See also zef_init_fields_compartment_table, zef_update.
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
        zef.h_compartment_table.ColumnWidth = [zef.h_compartment_table.ColumnWidth repmat({'1x'},1,missing_entries)];
    end
    zef_ui_fit_table(zef.h_compartment_table);
end

zef.compartment_tags = fliplr(zef.compartment_tags);

if nargout == 0
    assignin('base','zef',zef);
end
