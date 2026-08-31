function zef_set_compartment_color
%ZEF_SET_COMPARTMENT_COLOR  Figure-tool **Compartments:** list ButtonDownFcn.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. uisetcolor; maps h_compartment_visible_color.Value through
%   compartments in reverse tag order (same order zef_update_fig_details
%   used to fill the list). Writes zef.<tag>_color in base unless the
%   dialog was cancelled (color_vec==0). Wired in zef_figure_tool as
%   ButtonDownFcn with zef_update after. Does not itself redraw axes1.
%
%   See also zef_update_fig_details, zef_set_sensor_color.

color_vec = uisetcolor;
item_ind = zef_colored_list('value', evalin('base','zef.h_compartment_visible_color'));
if isempty(item_ind)
    return
end
item_ind = item_ind(1);
compartment_tags = evalin('base','zef.compartment_tags');

if not(isequal(color_vec,0))
    % List rows are reverse(compartment_tags).
    mapped = numel(compartment_tags) - item_ind + 1;
    if mapped >= 1 && mapped <= numel(compartment_tags)
        evalin('base',['zef.' compartment_tags{mapped} '_color = [' num2str(color_vec) '];']);
    end
end

end
