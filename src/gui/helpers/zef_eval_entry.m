function out_val = zef_eval_entry(in_var, entry_ind)
% --- Zeffiro documentation header ---
% zef_eval_entry — Zef eval entry.
%
% Purpose:
%   Zef eval entry.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   in_var
%   entry_ind
%
% Outputs:
%   out_val
%
% Calls (project):
%   zef_eval_entry
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[out_val] = zef_eval_entry(in_var, entry_ind)` with project root and `src` on the path.
% --- End Zeffiro documentation header


out_val = in_var(entry_ind);

end
