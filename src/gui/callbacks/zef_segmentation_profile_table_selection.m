function zef_segmentation_profile_table_selection(hObject,eventdata,handles)
%ZEF_SEGMENTATION_PROFILE_TABLE_SELECTION  CellSelectionCallback for the segmentation-profile table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_open_segmentation_profile (Settings → **Segmentation
%   profile**). Unique selected rows →
%   zef.segmentation_profile_row_selected; unique selected columns →
%   zef.segmentation_profile_column_selected. Those fields are what the
%   Add/Delete row and column menus read. There is no Apply callback in
%   this folder (Save writes the INI).
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_open_segmentation_profile.

segmentation_profile_row_selected = eventdata.Indices(:,1);
segmentation_profile_column_selected = unique(eventdata.Indices(:,2));
segmentation_profile_row_selected = unique(segmentation_profile_row_selected);
segmentation_profile_row_selected = segmentation_profile_row_selected(:)';
segmentation_profile_column_selected = segmentation_profile_column_selected(:)';
evalin('base',['zef.segmentation_profile_row_selected =[' num2str(segmentation_profile_row_selected) '];']);
evalin('base',['zef.segmentation_profile_column_selected =[' num2str(segmentation_profile_column_selected) '];']);

end
