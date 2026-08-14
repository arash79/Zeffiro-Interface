function [tree] = zef_dataBank_loadTreeNodes(tree)
%ZEF_DATABANK_LOADTREENODES  Load node .mat files into memory and delete them.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inverse of saveTreeNodes, used when savetodiskSwitch turns Off.
%   Folder is taken from the first node's matfile Source (strip through
%   'node_'). Each .data is replaced by load(Source). Then delete(folder
%   + 'node_*') removes the files. Assumes every node currently holds a
%   matfile (tree nonempty).
%
%   tree = zef_dataBank_loadTreeNodes(tree)
%
%   Inputs
%     tree  - zef.dataBank.tree with .data matfile handles.
%
%   Output
%     tree  - .data is an in-memory struct per node; matching files deleted.
%
%   See also zef_dataBank_saveTreeNodes.

%changes the data in the tree nodes from matFileObject to struct by loading
%the files
dbFieldNames=fieldnames(tree);

folder=extractBefore(tree.(dbFieldNames{1}).data.Properties.Source, 'node_');

for i=1:length(dbFieldNames)

    tree.(dbFieldNames{i}).data=load(tree.(dbFieldNames{i}).data.Properties.Source);

end
folder=strcat(folder, 'node_*');
delete(folder);

end
