function zef = zef_butterfly_plot(zef)
%ZEF_BUTTERFLY_PLOT  Multi-tools → **Butterfly plot**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. MenuSelectedFcn of h_menu_butterfly_plot (Text='Butterfly
%   plot' under Forward tools). zef_tool_start(...,
%   'zef_butterfly_plot_start', 1/4, 0) opens the butterfly window.
%   nargout==0 → assignin base. Does not itself plot time series; the
%   window **Plot** button does zef_update_butterfly_plot then
%   zef_make_butterfly_plot.
%
%   See also zef_butterfly_plot_start, zef_update_butterfly_plot.
if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_butterfly_plot_start',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end
