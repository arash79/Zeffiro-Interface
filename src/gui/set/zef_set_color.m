% --- Zeffiro documentation header ---
% function zef_set_color — Function zef set color.
%
% Purpose:
%   Function zef set color.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.h_compartment_color (read)
%
% Calls (project):
%   zef_set_color
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_set_color` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_set_color


color_vec = uisetcolor;
item_ind = evalin('base','zef.h_compartment_color.Value');
item_ind = length(evalin('base','zef.compartment_tags')) - item_ind + 1;
compartment_tag = evalin('base',['zef.compartment_tags{' num2str(item_ind) '}']);
evalin('base',['zef.' compartment_tag '_color = [' num2str(color_vec) '];']);

end
