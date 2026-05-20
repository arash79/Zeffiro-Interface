% --- Zeffiro documentation header ---
% dltType='gmm'; — Dlt Type='gmm';.
%
% Purpose:
%   Dlt Type='gmm';.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_delete
%   zef_dataBank_uiTreeDeleteHash
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `dltType='gmm';` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

dltType='gmm';

%dltType='reconstruction';

onlyIn='node';

allHashes=fieldnames(zef.dataBank.tree);
allHashes=allHashes(startsWith(allHashes, onlyIn));

i=1;

while i<=length(allHashes)

    if strcmp(zef.dataBank.tree.(allHashes{i}).type, dltType)
        zef.dataBank.hash=allHashes{i};
        zef.dataBank.tree=zef_dataBank_delete(zef.dataBank.tree, zef.dataBank.hash, 'false');
        %zef_dataBank_uiTreeDeleteHash(zef.dataBank.app.Tree, zef.dataBank.hash);
        allHashes=fieldnames(zef.dataBank.tree);
        allHashes=allHashes(startsWith(allHashes, onlyIn));

        i=1;
    else
        i=i+1;
    end

end
