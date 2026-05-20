function [info,columnNames] = zef_dataBank_showCurrent(zef, type)
% --- Zeffiro documentation header ---
% zef_dataBank_showCurrent — Zef data Bank show Current.
%
% Purpose:
%   Zef data Bank show Current.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   type
%
% Outputs:
%   info
%   columnNames
%
% Calls (project):
%   zef_dataBank_getData
%   zef_dataBank_showCurrent
%   zef_databank_showAll
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[info, columnNames]] = zef_dataBank_showCurrent(zef, type)` with project root and `src` on the path.
% --- End Zeffiro documentation header


tree.node.data=zef_dataBank_getData(zef, type);
tree.node.type=type;
[info, columnNames]=zef_databank_showAll(tree, type);

end
