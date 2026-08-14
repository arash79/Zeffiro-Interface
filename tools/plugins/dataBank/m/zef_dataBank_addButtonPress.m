function zef = zef_dataBank_addButtonPress(zef)
%ZEF_DATABANK_ADDBUTTONPRESS  Snapshot live zef onto the selected uitree node.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   addButton.ButtonPushedFcn in zef_open_dataBank. Reads Entrytype.Value,
%   calls zef_dataBank_getData, then zef_dataBank_add under the selected
%   node's NodeData (or 'node' if nothing is selected). Creates a uitreenode
%   with Text = tree.(hash).name and the treeMenu context menu. If
%   zef.dataBank.save2disk is 'On', writes folder/hash.mat and replaces
%   .data with a matfile handle. Refuses more than one selected parent.
%   Also used programmatically by zef_dataBank_add_data_item.
%
%   zef = zef_dataBank_addButtonPress(zef)
%
%   Inputs
%     zef  - session with dataBank.app, tree, Entrytype. nargin==0 → base.
%
%   Output
%     zef  - tree and uitree updated. nargout==0 → assignin base.
%
%   See also zef_dataBank_add, zef_dataBank_getData, zef_dataBank_add_data_item.

if nargin == 0
    zef = evalin('base','zef');
end

dbtype=zef.dataBank.app.Entrytype.Value;

if isempty(zef.dataBank.app.Tree.SelectedNodes) %either no selected or no node in tree, either way start on first level

    newNode= uitreenode(zef.dataBank.app.Tree);
    dbParentHash='node';

else
    if size(zef.dataBank.app.Tree.SelectedNodes,1)>1
        disp('cannot add to multiple nodes!');
        return;
    end

    newNode=uitreenode(zef.dataBank.app.Tree.SelectedNodes);
    dbParentHash=zef.dataBank.app.Tree.SelectedNodes.NodeData;

end

%if import maybe loop here

[zef.dataBank.tree, newNode.NodeData]=zef_dataBank_add(zef.dataBank.tree, dbParentHash, zef_dataBank_getData(zef, dbtype));

newNode.Text=zef.dataBank.tree.(newNode.NodeData).name;

if strcmp(zef.dataBank.save2disk, 'On')
    nodeData=zef.dataBank.tree.(newNode.NodeData).data;
    folderName=strcat(zef.dataBank.folder, newNode.NodeData);
    save(folderName, '-struct', 'nodeData');
    zef.dataBank.tree.(newNode.NodeData).data=matfile(folderName);

    clear nodeData folderName
end

newNode.ContextMenu=zef.dataBank.app.treeMenu;

if isempty(zef.dataBank.app.Tree.SelectedNodes)
    expand(zef.dataBank.app.Tree, 'all');
else
    expand(zef.dataBank.app.Tree.SelectedNodes);
end

clear dbtype dbParentHash newNode;

if nargout == 0
    assignin('base','zef',zef);
end
end
