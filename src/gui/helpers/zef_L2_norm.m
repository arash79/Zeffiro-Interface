function norm = zef_L2_norm(arr, dim)
% --- Zeffiro documentation header ---
% zef_L2_norm — Zef L2 norm.
%
% Purpose:
%   Zef L2 norm.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   arr
%   dim
%
% Outputs:
%   norm
%
% Calls (project):
%   zef_L2_norm
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[norm] = zef_L2_norm(arr, dim)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin == 2
    norm = sqrt(sum(arr.^2, dim));
else
    norm = sqrt(sum(arr.^2, 'all'));
end

end
