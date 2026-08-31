function [tree, hash] = zef_dataBank_add(tree, parentHash, data)
%ZEF_DATABANK_ADD  Insert a typed node under parentHash; return the new hash.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Core tree insert for Data Bank. Does not touch widgets or disk; the
%   Add path (zef_dataBank_addButtonPress) and importNode call this after
%   assembling a payload with zef_dataBank_getData. node.name is data.type,
%   or rec-<tag> when type is reconstruction and reconstruction_information.tag
%   exists. Hash is the first free sibling parentHash_i (i = 1,2,…).
%
%   [tree, hash] = zef_dataBank_add(tree, parentHash, data)
%
%   Inputs
%     tree        - zef.dataBank.tree struct (may be empty struct).
%     parentHash  - char, typically 'node' at the root or a child's NodeData.
%     data        - payload struct with at least .type (see getData).
%
%   Output
%     tree  - same struct plus tree.(hash) with .data, .type, .name, .hash.
%     hash  - char field name of the new node.
%
%   See also zef_dataBank_addButtonPress, zef_dataBank_getData.

% Payload is already assembled (getData / import). Build the node, then
% take the first free sibling hash under parentHash (parentHash_1, _2, …).
node=[];
node.data=data;
node.type=data.type;
node.name=data.type;

if strcmp(data.type, 'reconstruction') && isfield(node.data, 'reconstruction_information') && isfield(node.data.reconstruction_information, 'tag')
    node.name=strcat('rec-', node.data.reconstruction_information.tag);
end

i=1;
while isfield(tree, strcat(parentHash, '_', num2str(i)))
    i=i+1;
end
hash=strcat(parentHash, '_', num2str(i));

node.hash=hash;
tree.(hash)=node;

end
