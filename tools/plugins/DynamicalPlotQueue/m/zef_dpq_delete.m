function data_table = zef_dpq_delete(zef)
%ZEF_DPQ_DELETE  Drop the selected dynamical-plot-queue rows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   MenuSelectedFcn of h_dynamical_plot_queue_menu_delete. Removes rows
%   whose indices are in zef.dpq_selected (set by zef_dpq_selection) and
%   returns the remaining table. The menu then copies Data into
%   zef.dynamical_plot_queue_table.
%
%   data_table = zef_dpq_delete
%   data_table = zef_dpq_delete(zef)
%
%   After the drop, tries to point the script and description boxes at a
%   remaining row using the pre-delete remaining-index vector. Empty
%   table clears those boxes. No-arg form reads zef from base.
%
%   See also zef_dpq_add, zef_dpq_selection, zef_dpq_window.

if nargin == 0
    zef = evalin('base','zef');
end

data_table = eval('zef.h_dynamical_plot_queue_table.Data');

selected_ind = eval('zef.dpq_selected');
aux_ind = setdiff([1 : size(data_table,1)]', selected_ind);

data_table = data_table(aux_ind,:);

% Refresh the script/description boxes from a leftover row when possible.
if size(data_table,1) >= aux_ind
    eval(['zef.h_dynamical_plot_queue_script.Value = ''' data_table{aux_ind,1} ''';']);
    eval(['zef.h_dynamical_plot_queue_description.Value = ''' data_table{aux_ind,4} ''';']);
elseif aux_ind > 1
    eval(['zef.h_dynamical_plot_queue_script.Value = ''' data_table{aux_ind-1,1} ''';']);
    eval(['zef.h_dynamical_plot_queue_description.Value = ''' data_table{aux_ind-1,4} ''';']);
else
    eval(['zef.h_dynamical_plot_queue_script.Value = '' '';']);
    eval(['zef.h_dynamical_plot_queue_description.Value = '''';']);
end

end
