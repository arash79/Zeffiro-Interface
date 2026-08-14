function zef_transform_table_selection(hObject,eventdata,handles)
%ZEF_TRANSFORM_TABLE_SELECTION  CellSelectionCallback for the Transform UITable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_segmentation_tool onto h_transform_table.
%   evalin('base',...).
%
%   First selected row → zef.current_transform (1-based layer index on
%   current_tag). zef_init_transform_parameters fills the parameters
%   table (scaling, corrections, rotations, affine). Unique selected row
%   indices go to zef.transforms_selected for **Delete transform(s)**.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_delete_transform, zef_add_transform, zef_apply_transform.

transform_selected = eventdata.Indices(1);

evalin('base', ['zef.current_transform = ' num2str(transform_selected) ';']);
evalin('base','run(''zef_init_transform_parameters'')');

transforms_selected = eventdata.Indices(:,1);
transforms_selected = unique(transforms_selected);
transforms_selected = transforms_selected(:)';
evalin('base',['zef.transforms_selected =[' num2str(transforms_selected) '];']);

end
