function zef_dpq_selection(hObject,eventdata,handles)
%ZEF_DPQ_SELECTION  Table selection → zef.dpq_selected and the edit boxes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   CellSelectionCallback of h_dynamical_plot_queue_table (GUIDE-style
%   three-argument signature; hObject and handles are unused). Writes
%   selected row indices into base zef.dpq_selected and copies column 1
%   (script) and column 4 (description) of the first selected row into
%   the script and description boxes.
%
%   zef_dpq_selection(hObject, eventdata, handles)
%
%   Delete uses zef.dpq_selected. The script/description ValueChangedFcn
%   callbacks in zef_dpq_window write those boxes back into the selected
%   table row.
%
%   See also zef_dpq_delete, zef_dpq_window.

functions_selected = eventdata.Indices(:,1)';
evalin('base',['zef.dpq_selected = [' num2str(functions_selected)
 ']'';']);
evalin('base',['zef.h_dynamical_plot_queue_script.Value=zef.h_dynamical_plot_queue_table.Data{' num2str(functions_selected(1)) ',1};']);
evalin('base',['zef.h_dynamical_plot_queue_description.Value=zef.h_dynamical_plot_queue_table.Data{' num2str(functions_selected(1)) ',4};']);

end
