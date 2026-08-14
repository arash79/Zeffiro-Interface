function [tree] = zef_dataBank_importNode(tree, savePath, saveFile, parentHash, dataBank)
%ZEF_DATABANK_IMPORTNODE  Load one or more node .mat files under a parent hash.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by importNodeButtonPress when typeDropDown.Value is 'Node'. Each
%   file is load()ed as a node with .data and .name; zef_dataBank_add
%   inserts .data under parentHash and the stored .name is copied onto the
%   new hash. If dataBank.save2disk is 'On', the payload is also written
%   to dataBank.folder/hash.mat and .data becomes a matfile handle.
%
%   tree = zef_dataBank_importNode(tree, savePath, saveFile, parentHash, dataBank)
%
%   Inputs
%     tree        - zef.dataBank.tree.
%     savePath    - folder from uigetfile (includes trailing filesep).
%     saveFile    - char or cellstr of file names.
%     parentHash  - hash of the selected uitree parent, or 'node'.
%     dataBank    - zef.dataBank (uses .save2disk and .folder).
%
%   Output
%     tree  - new child node(s) added.
%
%   See also zef_dataBank_importNodeButtonPress, zef_dataBank_importDataBank.

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
