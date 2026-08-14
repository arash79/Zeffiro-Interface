function zef = zef_dataBank_setData(zef)
%ZEF_DATABANK_SETDATA  Copy the selected tree node back onto live zef fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   loadMenu and loadwithparentsMenu (and the DataTable copies) in
%   zef_open_dataBank: they set zef.dataBank.loadParents then call
%   zef_dataBank_getHashForMenu and this function. For type 'gmm' calls
%   zef_load_GMM + zef_GMM_update. Otherwise copies every field of
%   tree.(hash).data onto zef except names starting with Properties or type
%   (so a matfile handle is not copied as a whole). If loadParents is true,
%   strips the last _segment from the hash and recurses until the hash is
%   'node'. Overwrites matching zef fields (L, measurements, reconstruction,
%   …). Analysis scripts also set zef.dataBank.hash and call this directly.
%
%   zef = zef_dataBank_setData(zef)
%
%   Inputs
%     zef  - session; uses zef.dataBank.hash and .tree. nargin==0 → base.
%
%   Output
%     zef  - live fields replaced from the node. nargout==0 → assignin base.
%
%   See also zef_dataBank_getData, zef_dataBank_getHashForMenu.

if nargin == 0
    zef = evalin('base','zef')
end

dbFieldNames=fieldnames(zef.dataBank.tree.(zef.dataBank.hash).data);

for dbi=1:length(dbFieldNames)
    if strcmp(zef.dataBank.tree.(zef.dataBank.hash).type, 'gmm')

        zef_load_GMM(zef.dataBank.tree.(zef.dataBank.hash).data);
        zef_GMM_update;

    else

        if ~(startsWith(dbFieldNames{dbi}, 'Properties')||startsWith(dbFieldNames{dbi}, 'type')) %prevents the copy of the properties if the data is an matObject
            zef.(dbFieldNames{dbi})=zef.dataBank.tree.(zef.dataBank.hash).data.(dbFieldNames{dbi});
        end

    end

end

if zef.dataBank.loadParents

    % Walk to the parent hash: node_1_2_3 → node_1_2 → node_1 → stop at 'node'.
    zef.dataBank.hash=reverse(zef.dataBank.hash);
    zef.dataBank.hash=extractAfter(zef.dataBank.hash, '_');
    zef.dataBank.hash=reverse(zef.dataBank.hash);

    if ~strcmp(zef.dataBank.hash, 'node')
        zef_dataBank_setData;
    end

end

if nargout == 0
    assignin('base','zef',zef);
end

end
