function zef_set_size_change_function(h_window,type,scale_positions,exclude_cell)
%ZEF_SET_SIZE_CHANGE_FUNCTION  Install SizeChangedFcn on a tool window at creation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Turns AutoResizeChildren off, stores CurrentSize /
%   ScalePositions / ExcludeCell / RelativeSize in UserData (type 2
%   also captures zef_get_relative_size), and sets SizeChangedFcn to
%   @(src,evt) zef_window_manager('on_size_changed', src) so R2025a+
%   arrange/tile can invoke it without gcbo.
%
%   See also zef_window_manager, zef_change_size_function.
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

exclude_eval = {};
if ischar(exclude_cell) || isstring(exclude_cell)
    try
        exclude_eval = eval(char(exclude_cell));
    catch
        exclude_eval = {};
    end
elseif iscell(exclude_cell)
    exclude_eval = exclude_cell;
end

ud = struct;
ud.CurrentSize = get(h_window,'Position');
ud.ScalePositions = scale_positions;
ud.ExcludeCell = exclude_eval;
if type == 2
    ud.RelativeSize = zef_get_relative_size(h_window);
else
    ud.RelativeSize = [];
end
h_window.UserData = ud;
% Function handle (not a gcbo character callback): R2025a+ SizeChangedFcn
% can be a handle, and arrange/tile must be able to invoke it without gcbo.
set(h_window,'SizeChangedFcn', @(src, evt) zef_window_manager('on_size_changed', src));

warning on;

end
