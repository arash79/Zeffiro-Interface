%ZEF_SET_FIGURE_CURRENT_SIZE  Figure-tool SizeChangedFcn (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. When zef.zeffiro_current_size is non-empty, updates the cell
%   entry keyed by str2num(gcf Tag) via zef_change_size_function,
%   excluding children tagged Colorbar and image_details. Needs workspace
%   zef.
%
%   See also zef_change_size_function, zef_set_size_change_function.
if not(isempty(zef.zeffiro_current_size)); zef.zeffiro_current_size{str2num(get(gcf,'Tag'))} = zef_change_size_function(gcf,zef.zeffiro_current_size{str2num(get(gcf,'Tag'))},[],{'Colorbar','image_details'}); end;
