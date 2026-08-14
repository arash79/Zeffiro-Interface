function zef_set_color
%ZEF_SET_COLOR  uisetcolor for a compartment (legacy list, not Figure-tool lists).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Reads zef.h_compartment_color.Value, maps through reversed
%   compartment_tags (same flip as the Segmentation table), writes
%   zef.<tag>_color in base. The Figure-tool **Compartments:** list uses
%   zef_set_compartment_color instead. Does not replot; callers run
%   zef_update.
%
%   See also zef_set_compartment_color, zef_set_sensor_color.

color_vec = uisetcolor;
item_ind = evalin('base','zef.h_compartment_color.Value');
item_ind = length(evalin('base','zef.compartment_tags')) - item_ind + 1;
compartment_tag = evalin('base',['zef.compartment_tags{' num2str(item_ind) '}']);
evalin('base',['zef.' compartment_tag '_color = [' num2str(color_vec) '];']);

end
