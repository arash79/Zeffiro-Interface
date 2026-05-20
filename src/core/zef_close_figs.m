%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if isvalid(zef — If isvalid(zef.
%
% Purpose:
%   If isvalid(zef.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Zef fields (observed):
%   zef.h_fig_aux (read, write)
%   zef.h_zeffiro (read)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isvalid(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if isvalid(zef.h_zeffiro)
    zef.h_zeffiro.DeleteFcn = '';
end
zef.h_fig_aux = findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Figure tool*');
%zef.h_fig_aux = findall(groot, '-property','ZefFig');
zef.h_fig_aux = zef.h_fig_aux(find(isvalid(zef.h_fig_aux)));
delete(zef.h_fig_aux);
zef = rmfield(zef,'h_fig_aux');
zef_figure_tool;
