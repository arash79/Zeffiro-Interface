function zef = zef_start_dataBank(zef)
% --- Zeffiro documentation header ---
% zef_start_dataBank — Zef start data Bank.
%
% Purpose:
%   Zef start data Bank.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_start_dataBank
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_start_dataBank(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_open_dataBank',1/2,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
