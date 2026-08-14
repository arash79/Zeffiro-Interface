function zef_delete_transform
%ZEF_DELETE_TRANSFORM  Drop selected transform-table rows when unlocked.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click Transform → **Delete transform(s)**
%   (h_menu_delete_transform; MenuSelectedFcn "zef_delete_transform;").
%   Rows come from zef.transforms_selected (set by
%   zef_transform_table_selection). Does nothing when
%   lock_transforms_on is true.
%
%   Function with no arguments. evalin('base',...).
%
%   For each selected row, column 1 (Index) is used as a linear index
%   into h_transform_table.Data and that cell is set to NaN.
%   zef_update_transform then drops those layers from current_tag
%   scaling/correction/rotation/affine_transform arrays.
%
%   See also zef_add_transform, zef_transform_table_selection.

if not(evalin('base','zef.lock_transforms_on'))

    table_data = evalin('base','zef.h_transform_table.Data');
    transforms_selected = evalin('base','zef.transforms_selected');

    for i = 1 : length(transforms_selected)

        % Column 1 Index as linear index → NaN delete flag for zef_update_transform.
        evalin('base',['zef.h_transform_table.Data{' num2str(table_data{transforms_selected(i),1}) '} = NaN;'])

    end

    evalin('base','run(''zef_update_transform'')');

end

end
