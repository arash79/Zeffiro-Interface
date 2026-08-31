%ZEF_SIZE_CHANGE  Figure-tool SizeChangedFcn installer (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Turns AutoResizeChildren off, stores Position in
%   zef.zeffiro_current_size{zef_fig_num}, Tags the figure with that index,
%   and sets SizeChangedFcn to zef_change_size_function excluding Colorbar
%   and image_details. Called when a Figure-tool window is created.
%
%   See also zef_change_size_function, zef_fig_num.

set(gcf,'AutoResizeChildren','off');
zef.zeffiro_current_size{zef_fig_num} = get(gcf,'Position');
set(gcf,'Tag',num2str(zef_fig_num));
set(gcf,'SizeChangedFcn','zef.zeffiro_current_size{str2num(get(gcf,''Tag''))} = zef_change_size_function(gcf,zef.zeffiro_current_size{str2num(get(gcf,''Tag''))},[],{''Colorbar'',''image_details''});');
