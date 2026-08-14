function zef_forward_simulation_table_selection(hObject,eventdata,handles)
%ZEF_FORWARD_SIMULATION_TABLE_SELECTION  CellSelectionCallback for the Mesh-tool script table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_mesh_tool onto h_forward_simulation_table (columns
%   Name / Description / Script). evalin('base',...).
%
%   Unique selected rows → zef.forward_simulation_selected (used by the
%   table context **Add** / **Delete** and by **Run script**, which evals
%   the selected INI cell). First selected column →
%   zef.forward_simulation_column_selected. Copies that cell's text into
%   h_forward_simulation_script.Value.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_run_forward_simulation, zef_mesh_tool.

forward_simulation_selected = eventdata.Indices(:,1);
forward_simulation_column_selected = eventdata.Indices(1,2);
forward_simulation_selected = unique(forward_simulation_selected);
forward_simulation_selected = forward_simulation_selected(:)';
evalin('base',['zef.forward_simulation_selected =[' num2str(forward_simulation_selected) '];']);
evalin('base',['zef.forward_simulation_column_selected =[' num2str(forward_simulation_column_selected) '];']);
aux_char = char(evalin('base',['zef.h_forward_simulation_table.Data{' num2str(forward_simulation_selected(1)) ',' num2str(forward_simulation_column_selected) '}']));
evalin('base',['zef.h_forward_simulation_script.Value = ''' aux_char ''';']);

end
