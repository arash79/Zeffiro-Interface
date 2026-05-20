function [info, columnNames] = zef_dataBank_WorkingSpaceInfo(tree, hash)
% --- Zeffiro documentation header ---
% zef_dataBank_WorkingSpaceInfo — Zef data Bank Working Space Info.
%
% Purpose:
%   Zef data Bank Working Space Info.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%   hash
%
% Outputs:
%   info
%   columnNames
%
% Calls (project):
%   zef_dataBank_WorkingSpaceInfo
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[info, columnNames]] = zef_dataBank_WorkingSpaceInfo(tree, hash)` with project root and `src` on the path.
% --- End Zeffiro documentation header


columnNames={'hash', 'node type', 'name'};
if ~iscell(hash)
    hash={hash};
end
info=cell(length(hash), 3);

for i=1:length(hash)

    info{i,1}=hash{i};
    info{i,2}=tree.(hash{i}).type;
    info{i,3}=tree.(hash{i}).name;

end

end
