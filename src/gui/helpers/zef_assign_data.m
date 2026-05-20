function zef = zef_assign_data(zef, zef_data)
% --- Zeffiro documentation header ---
% zef_assign_data — Zef assign data.
%
% Purpose:
%   Zef assign data.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   zef_data
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_assign_data
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_assign_data(zef, zef_data)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin == 0
    zef_data = evalin('base','zef_data');
    if not(isempty(evalin('base','whos(''zef'')')))
        zef = evalin('base','zef');
    else
        evalin('base','zef = struct;');
    end
end

fieldnames_aux = eval('fieldnames(zef_data)');
for zef_i = 1 : length(fieldnames_aux)
    zef.(fieldnames_aux{zef_i}) = zef_data.(fieldnames_aux{zef_i});
end

if nargout == 0
    assignin('base','zef',zef);
    evalin('base','clear zef_data;');
end

end
