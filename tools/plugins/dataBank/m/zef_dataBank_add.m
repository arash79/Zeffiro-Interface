function [tree, hash] = zef_dataBank_add(tree, parentHash, data)
% --- Zeffiro documentation header ---
% zef_dataBank_add — Zef data Bank add.
%
% Purpose:
%   Zef data Bank add.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%   parentHash
%   data
%
% Outputs:
%   tree
%   hash
%
% Calls (project):
%   zef_dataBank_add
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[tree, hash]] = zef_dataBank_add(tree, parentHash, data)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
