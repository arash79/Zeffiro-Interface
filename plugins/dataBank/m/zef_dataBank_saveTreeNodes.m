function [tree] = zef_dataBank_saveTreeNodes(tree, folder)
%ZEF_DATABANK_SAVETREENODES  Write each node payload as folder/hash.mat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used when savetodiskSwitch turns On. For every field, save(...,
%   '-struct', 'nodeData') then replace .data with matfile(folder+hash).
%   Subsequent Add/import with save2disk On writes the same way.
%
%   tree = zef_dataBank_saveTreeNodes(tree, folder)
%
%   Inputs
%     tree    - zef.dataBank.tree (payloads currently in-memory structs).
%     folder  - zef.dataBank.folder, including trailing filesep.
%
%   Output
%     tree  - same nodes; .data is a matfile handle per hash.
%
%   See also zef_dataBank_loadTreeNodes, zef_dataBank_saveTreeNodeSwitchChange.

%changes the data in the nodes of the tree from
% struct to matFileObject by saving to folder
dbFieldNames=fieldnames(tree);

for i=1:length(dbFieldNames)

    nodeData=tree.(dbFieldNames{i}).data;
    folderName=strcat(folder, dbFieldNames{i});
    save(folderName, '-struct', 'nodeData');
    tree.(dbFieldNames{i}).data=matfile(folderName);

end

end
