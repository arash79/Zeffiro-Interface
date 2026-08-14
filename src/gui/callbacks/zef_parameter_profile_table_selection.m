function zef_parameter_profile_table_selection(hObject,eventdata,handles)
%ZEF_PARAMETER_PROFILE_TABLE_SELECTION  CellSelectionCallback for the parameter-profile table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_open_parameter_profile (Settings → **Parameter
%   profile**). Unique selected rows → zef.parameter_profile_selected
%   for that table's Add/Delete menus. Apply writes the INI then
%   zef_apply_parameter_profile.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_apply_parameter_profile, zef_open_parameter_profile.

parameter_profile_selected = eventdata.Indices(:,1);
parameter_profile_selected = unique(parameter_profile_selected);
parameter_profile_selected = parameter_profile_selected(:)';
evalin('base',['zef.parameter_profile_selected =[' num2str(parameter_profile_selected) '];']);

end
