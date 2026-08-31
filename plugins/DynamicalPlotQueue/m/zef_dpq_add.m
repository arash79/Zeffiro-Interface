function data_table = zef_dpq_add(zef)
%ZEF_DPQ_ADD  Append a blank dynamical-plot-queue row.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   MenuSelectedFcn of h_dynamical_plot_queue_menu_add (wired in
%   zef_dpq_window). Reads the current uitable Data, appends
%   {'', true, 'static', ''}, and returns the cell so the menu can assign
%   it back to h_dynamical_plot_queue_table.Data. Does not write
%   zef.dynamical_plot_queue_table; the table CellEditCallback does that
%   on edit. List-menu rows are added separately in zef_dpq_window.
%
%   data_table = zef_dpq_add
%   data_table = zef_dpq_add(zef)
%
%   With no argument, zef is taken from the base workspace (the menu
%   path). Column 2 is a logical true, unlike the List menu which stores
%   the character 'true'.
%
%   See also zef_dpq_delete, zef_dpq_window, zef_plot_dpq.

if nargin == 0
    zef = evalin('base','zef');
end

data_table = eval('zef.h_dynamical_plot_queue_table.Data');

% {script, enabled, static|dynamical, description}
data_table(end+1,:) =  {'',true,'static',''};

end
