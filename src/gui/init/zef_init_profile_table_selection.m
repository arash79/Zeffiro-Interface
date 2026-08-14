function zef_init_profile_table_selection(hObject,eventdata,handles)
%ZEF_INIT_PROFILE_TABLE_SELECTION  CellSelectionCallback for Pre-settings profile table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function (GUIDE-style signature). Writes unique selected row indices
%   to zef.init_profile_selected in base so the Add/Delete menus in
%   zef_open_init_profile know where to insert/remove. Does not edit Data.
%
%   See also zef_open_init_profile.
init_profile_selected = eventdata.Indices(:,1);
init_profile_selected = unique(init_profile_selected);
init_profile_selected = init_profile_selected(:)';
evalin('base',['zef.init_profile_selected =[' num2str(init_profile_selected) '];']);
end
