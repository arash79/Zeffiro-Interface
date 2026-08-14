%ZEF_CLOSE_TOOLS  Close plugin/tool windows, keeping segmentation, figure, and menu.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Selects figures named "ZEFFIRO Interface:*" then setdiff's out
%   Segmentation tool, Figure tool, and Menu tool windows before delete.
%
%   Workspace
%     zef  - session struct; temporary h_tools_aux is removed.
%
%   See also zef_close_figs, zef_close_all.


zef.h_tools_aux = findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface:*');
zef.h_tools_aux = setdiff(zef.h_tools_aux, findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Segmentation tool*'));
zef.h_tools_aux = setdiff(zef.h_tools_aux, findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Figure tool*'));
zef.h_tools_aux = setdiff(zef.h_tools_aux, findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Menu tool*'));
%zef.h_tools_aux = findall(groot,'-property','ZefTool','-not','ZefTool','zef_segmentation_tool','-not','ZefTool','zef_menu_tool');
zef.h_tools_aux = zef.h_tools_aux(find(isvalid(zef.h_tools_aux)));
delete(zef.h_tools_aux);
zef = rmfield(zef,'h_tools_aux');
