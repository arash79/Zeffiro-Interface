function zef = zef_dataBank_saveTreeNodeSwitchChange(zef)
%ZEF_DATABANK_SAVETREENODESWITCHCHANGE  savetodiskSwitch: dump nodes to disk or load them back.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   savetodiskSwitch.ValueChangedFcn in zef_open_dataBank. Copies the
%   switch Value to zef.dataBank.save2disk. 'On' → saveTreeNodes into
%   zef.dataBank.folder (payloads become matfile handles). 'Off' →
%   loadTreeNodes (loads structs and deletes node_* files). Shows
%   zef_waitbar during the copy.
%
%   zef = zef_dataBank_saveTreeNodeSwitchChange(zef)
%
%   Inputs
%     zef  - session with savetodiskSwitch, tree, and folder. nargin==0 → base.
%
%   Output
%     zef  - tree payloads swapped. nargout==0 → assignin base.
%
%   See also zef_dataBank_saveTreeNodes, zef_dataBank_loadTreeNodes.

if nargin == 0
    zef = evalin('base','zef')
end

zef.dataBank.save2disk=zef.dataBank.app.savetodiskSwitch.Value;

if strcmp(zef.dataBank.save2disk, 'Off') %deleting the files
    fwait= zef_waitbar(0,1, 'loading and deleting the data. Please wait');
    zef.dataBank.tree=zef_dataBank_loadTreeNodes(zef.dataBank.tree);
    close(fwait);

end

if strcmp(zef.dataBank.save2disk, 'On') %saving the files
    fwait= zef_waitbar(0,1, 'Saving the data. Please wait');
    zef.dataBank.tree=zef_dataBank_saveTreeNodes(zef.dataBank.tree, zef.dataBank.folder);
    close(fwait);
end

clear fwait

if nargout == 0
    assignin('base','zef',zef);
end

end
