function [tree] = zef_dataBank_importNode(tree, savePath, saveFile, parentHash, dataBank)
% --- Zeffiro documentation header ---
% zef_dataBank_importNode — Zef data Bank import Node.
%
% Purpose:
%   Zef data Bank import Node.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%   savePath
%   saveFile
%   parentHash
%   dataBank
%
% Outputs:
%   tree
%
% Calls (project):
%   zef_dataBank_add
%   zef_dataBank_importNode
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[tree] = zef_dataBank_importNode(tree, savePath, saveFile, parentHash, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if ~iscell(saveFile)
    node=load(strcat(savePath, saveFile));
    [tree, hash]=zef_dataBank_add(tree, parentHash, node.data);
    tree.(hash).name=node.name;

    if strcmp(dataBank.save2disk, 'On')
        folderName=strcat(dataBank.folder, hash);
        data=node.data;
        save(folderName, '-struct', 'data');
        tree.(hash).data=matfile(folderName);
    end

else
    for i=1:length(saveFile)
        node=load(strcat(savePath, saveFile{i}));
        [tree, hash]=zef_dataBank_add(tree, parentHash, node.data);
        tree.(hash).name=node.name;

        if strcmp(dataBank.save2disk, 'On')
            folderName=strcat(dataBank.folder, hash);
            data=node.data;
            save(folderName, '-struct', 'data');
            tree.(hash).data=matfile(folderName);
        end
    end
end

end
