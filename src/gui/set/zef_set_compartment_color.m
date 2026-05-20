% --- Zeffiro documentation header ---
% function zef_set_compartment_color — Function zef set compartment color.
%
% Purpose:
%   Function zef set compartment color.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.h_compartment_visible_color (read)
%
% Calls (project):
%   zef_set_compartment_color
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_set_compartment_color` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_set_compartment_color


color_vec = uisetcolor;
item_ind = evalin('base','zef.h_compartment_visible_color.Value');
compartment_tags = evalin('base','zef.compartment_tags');

if not(isequal(color_vec,0))

zef_j = 0;
for zef_i = length(compartment_tags) : -1 : 1
    if evalin('base',['zef.' compartment_tags{zef_i} '_on']) && evalin('base',['zef.' compartment_tags{zef_i} '_visible'])
        zef_j = zef_j + 1;

        if zef_j == item_ind
            item_ind = zef_i;
            break;
        end

    end
end

evalin('base',['zef.' compartment_tags{item_ind} '_color = [' num2str(color_vec) '];']);

end

end
