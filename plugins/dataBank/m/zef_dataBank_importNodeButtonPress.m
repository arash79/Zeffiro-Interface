function zef = zef_dataBank_importNodeButtonPress(zef)
%ZEF_DATABANK_IMPORTNODEBUTTONPRESS  Import a node file or a whole-bank .mat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   importButton.ButtonPushedFcn in zef_open_dataBank. typeDropDown.Value
%   'Node' → uigetfile MultiSelect on, then importNode. Otherwise a single
%   dataBank file via importDataBank. Parent is the selected uitree node
%   (or 'node' if none). Refuses multiple selected parents. Then
%   zef_dataBank_refreshTree (no output, so base workspace).
%
%   zef = zef_dataBank_importNodeButtonPress(zef)
%
%   Inputs
%     zef  - session with dataBank.app and tree. nargin==0 → base.
%
%   Output
%     zef  - tree updated in the returned struct; refreshTree also assignin's.
%
%   See also zef_dataBank_importNode, zef_dataBank_importDataBank.

if nargin == 0
    zef = evalin('base','zef')
end

if strcmp(zef.dataBank.app.typeDropDown.Value, 'Node')
    [savefile,savepath] = uigetfile('*','Select One or More Node Files','MultiSelect', 'on');
else
    [savefile,savepath] = uigetfile('*','Select a dataBank file','MultiSelect', 'off');
end

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

if strcmp(zef.dataBank.app.typeDropDown.Value, 'Node')
    zef.dataBank.tree=zef_dataBank_importNode(zef.dataBank.tree, savepath, savefile, dbParentHash, zef.dataBank);
else
    zef.dataBank.tree=zef_dataBank_importDataBank(zef.dataBank.tree, savepath, savefile, dbParentHash, zef.dataBank);
end

zef_dataBank_refreshTree;

clear savefile savepath dbParentHash

end
