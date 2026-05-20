% --- Zeffiro documentation header ---
% tree.all=zef.dataBank — Tree.all=zef.data Bank.
%
% Purpose:
%   Tree.all=zef.data Bank.
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
%   Programmatic: Call `tree.all=zef.dataBank` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

tree.all=zef.dataBank.tree;

for iii=1:3

    switch iii
        case 1
            typ='Prob';
        case 2
            typ='Comp';
        case 3
            typ='kmeans';
    end

    dltType='gmm';

    onlyIn='node';

    allHashes=fieldnames(zef.dataBank.tree);
    allHashes=allHashes(startsWith(allHashes, onlyIn));

    i=1;
    while i<=length(allHashes)

        if strcmp(zef.dataBank.tree.(allHashes{i}).type, dltType) && (~contains(zef.dataBank.tree.(allHashes{i}).name, typ) || contains(zef.dataBank.tree.(allHashes{i}).name, '25'))
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

    tree.(typ)=zef.dataBank.tree;

    zef.dataBank.tree=tree.all;

end

subIndex=1;
figure;
for iii=1:3

    switch iii
        case 1
            typ='Comp';
        case 2
            typ='Prob';
        case 3
            typ='kmeans';
    end

    zef.dataBank.tree=tree.(typ);
    p_outputNew_subplot;

end
