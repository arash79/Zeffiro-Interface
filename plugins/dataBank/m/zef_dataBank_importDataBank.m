function [tree] = zef_dataBank_importDataBank(tree, savePath, saveFile, parentHash, dataBank)
%ZEF_DATABANK_IMPORTDATABANK  Graft a saved tree .mat under a parent hash.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   importNodeButtonPress when typeDropDown is not 'Node'. load()s the
%   file as a tree, sortTree + rebuildTree, then add()s node_1's payload
%   under parentHash. Remaining hashes are remapped: first numeric token
%   shifted by (new first-hash last index − 1), then prefixed with the
%   parent path numbers. Optional save2disk writes each payload to
%   dataBank.folder. The save2disk block for node_1 is duplicated in the
%   body (same write twice).
%
%   tree = zef_dataBank_importDataBank(tree, savePath, saveFile, parentHash, dataBank)
%
%   Inputs
%     tree, savePath, saveFile, parentHash, dataBank  - as importNode.
%
%   Output
%     tree  - current bank plus the imported forest under the parent.
%
%   See also zef_dataBank_importNode, zef_dataBank_number2hash.

dataTree=load(strcat(savePath, saveFile));

dataTree=zef_dataBank_sortTree(dataTree);
dataTree=zef_dataBank_rebuildTree(dataTree);

data=dataTree.node_1.data;
[tree, firsthash]=zef_dataBank_add(tree, parentHash, data);
tree.(firsthash).name=dataTree.node_1.name;

if strcmp(dataBank.save2disk, 'On')
    folderName=strcat(dataBank.folder, firsthash);
    save(folderName, '-struct', 'data');
    tree.(firsthash).data=matfile(folderName);
end

if strcmp(dataBank.save2disk, 'On')
    folderName=strcat(dataBank.folder, firsthash);
    save(folderName, '-struct', 'data');
    tree.(firsthash).data=matfile(folderName);
end

phash=str2double(regexp(parentHash, '(?<num>\d+)', 'match'));

firsthash=str2double(regexp(firsthash, '(?<num>\d+)', 'match'));

hashList=fieldnames(dataTree);

correctionNumber=firsthash(end)-1;
for i=2:length(hashList)
    hash=str2double(regexp(hashList{i}, '(?<num>\d+)', 'match'));
    hash(1)=hash(1)+correctionNumber;
    hash=[phash, hash];
    hash=zef_dataBank_number2hash(hash);

    tree.(hash)=dataTree.(hashList{i});
    tree.(hash).hash=hash;
    if strcmp(dataBank.save2disk, 'On')
        data=dataTree.(hashList{i}).data;
        folderName=strcat(dataBank.folder, hash);
        save(folderName, '-struct', 'data');
        tree.(hash).data=matfile(folderName);
    end

end

end
