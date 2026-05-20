function zef_segmentation_profile_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_segmentation_profile_table_selection — Zef segmentation profile table selection.
%
% Purpose:
%   Zef segmentation profile table selection.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   hObject
%   eventdata
%   handles
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.segmentation_profile_column_selected (read, write)
%   zef.segmentation_profile_row_selected (read, write)
%
% Calls (project):
%   zef_segmentation_profile_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_segmentation_profile_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


segmentation_profile_row_selected = eventdata.Indices(:,1);
segmentation_profile_column_selected = unique(eventdata.Indices(:,2));
segmentation_profile_row_selected = unique(segmentation_profile_row_selected);
segmentation_profile_row_selected = segmentation_profile_row_selected(:)';
segmentation_profile_column_selected = segmentation_profile_column_selected(:)';
evalin('base',['zef.segmentation_profile_row_selected =[' num2str(segmentation_profile_row_selected) '];']);
evalin('base',['zef.segmentation_profile_column_selected =[' num2str(segmentation_profile_column_selected) '];']);

end
