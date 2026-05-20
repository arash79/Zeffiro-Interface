function zef_set_size_change_function(h_window,type,scale_positions,exclude_cell)
% --- Zeffiro documentation header ---
% zef_set_size_change_function — Zef set size change function.
%
% Purpose:
%   Zef set size change function.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   h_window
%   type
%   scale_positions
%   exclude_cell
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_aux (read, write)
%
% Calls (project):
%   zef_change_size_function
%   zef_get_relative_size
%   zef_set_size_change_function
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_size_change_function(h_window, type, scale_positions, exclude_cell)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin < 2
    type = 2;
end

if nargin < 3
    scale_positions = 1;
end

if isempty(scale_positions)
    scale_positions = 1;
end

if nargin < 4
    exclude_cell = 'cell(0)';
end

if isprop(h_window,'AutoResizeChildren')
    set(h_window,'AutoResizeChildren','off');
end
warning off;

if type == 1
    h_window.UserData = struct;
    h_window.UserData.CurrentSize = get(h_window,'Position');
    set(h_window,'SizeChangedFcn',['zef.h_aux = get(gcbo,''UserData''); zef.h_aux.CurrentSize = zef_change_size_function(gcbo,getfield(get(gcbo,''UserData''),''CurrentSize''),[],' exclude_cell ',' num2str(scale_positions) ');set(gcbo,''UserData'',zef.h_aux);']);
end

if type == 2
    h_window.UserData = struct;
    h_window.UserData.CurrentSize = get(h_window,'Position');
    h_window.UserData.RelativeSize = zef_get_relative_size(h_window);
    set(h_window,'SizeChangedFcn',['zef.h_aux = get(gcbo,''UserData''); zef.h_aux.CurrentSize = zef_change_size_function(gcbo,getfield(get(gcbo,''UserData''),''CurrentSize''),getfield(get(gcbo,''UserData''),''RelativeSize''),' exclude_cell ',' num2str(scale_positions) ');set(gcbo,''UserData'',zef.h_aux);']);
end

warning on;

end
