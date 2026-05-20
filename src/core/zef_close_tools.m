%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Zef fields (observed):
%   zef.h_tools_aux (read, write)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.h_tools_aux = findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface:*');
zef.h_tools_aux = setdiff(zef.h_tools_aux, findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Segmentation tool*'));
zef.h_tools_aux = setdiff(zef.h_tools_aux, findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Figure tool*'));
zef.h_tools_aux = setdiff(zef.h_tools_aux, findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Menu tool*'));
%zef.h_tools_aux = findall(groot,'-property','ZefTool','-not','ZefTool','zef_segmentation_tool','-not','ZefTool','zef_menu_tool');
zef.h_tools_aux = zef.h_tools_aux(find(isvalid(zef.h_tools_aux)));
delete(zef.h_tools_aux);
zef = rmfield(zef,'h_tools_aux');
