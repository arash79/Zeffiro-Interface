%ZEF_CLOSE_FIGS  Close Figure-tool windows and reopen a fresh figure tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Clears DeleteFcn on the main visualization figure if it is
%   still valid, deletes every figure whose Name matches
%   "ZEFFIRO Interface: Figure tool*", then calls zef_figure_tool.
%
%   Workspace
%     zef  - session struct; temporary h_fig_aux is removed.
%
%   See also zef_figure_tool, zef_close_tools, zef_close_all.


if isvalid(zef.h_zeffiro)
    zef.h_zeffiro.CloseRequestFcn = 'closereq;';
    zef.h_zeffiro.DeleteFcn = '';
end
zef.h_fig_aux = findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Figure tool*');
zef.h_fig_aux = zef.h_fig_aux(find(isvalid(zef.h_fig_aux)));
delete(zef.h_fig_aux);
zef = rmfield(zef,'h_fig_aux');
zef_figure_tool;
