function [workingHashes] = zef_dataBank_hashToWorkingSpace(newHash, workingHashes)
% --- Zeffiro documentation header ---
% zef_dataBank_hashToWorkingSpace — Zef data Bank hash To Working Space.
%
% Purpose:
%   Zef data Bank hash To Working Space.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   newHash
%   workingHashes
%
% Outputs:
%   workingHashes
%
% Calls (project):
%   zef_dataBank_hashToWorkingSpace
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[workingHashes] = zef_dataBank_hashToWorkingSpace(newHash, workingHashes)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if ~iscell(newHash)
    newHash={newHash};
end

if ~iscell(workingHashes)
    workingHashes={workingHashes};
end

for i=1:length(newHash)
    duplicate=0;
    for wh=1:length(workingHashes)

        if strcmp(newHash{i}, workingHashes{wh})
            duplicate=1;
        end

    end
    if ~duplicate
        workingHashes{end+1}=newHash{i};
    end

end

end
