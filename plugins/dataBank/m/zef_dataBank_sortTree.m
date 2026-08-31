function [tree, newText] = zef_dataBank_sortTree(tree)
%ZEF_DATABANK_SORTTREE  Order tree fields by numeric hash suffix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sorts hashes so that node_11 comes after node_7 (string fieldnames
%   would not). Extracts every digit run from each name, pads shorter
%   paths with 0, sortrows, then orderfields. Used after delete and before
%   rebuildTree / hash2tree. If tree is not a struct, uses properties()
%   and drops 'Properties' (matfile-like). orderfields runs only for structs.
%
%   [tree, newText] = zef_dataBank_sortTree(tree)
%
%   Inputs
%     tree  - zef.dataBank.tree struct (or object with hash properties).
%
%   Output
%     tree     - same values, fields in numeric hash order.
%     newText  - cellstr of hashes in that order (node_i_j via number2hash).
%
%   See also zef_dataBank_rebuildTree, zef_dataBank_number2hash.

% Sort by the numeric tokens of the hashes so e.g. node_11 > node_7.
if isstruct(tree)
    text=fieldnames(tree);
else
    text=properties(tree);

    for i=1:length(text)
        if strcmp(text{i}, 'Properties')
            text(i)=[];
            break;
        end
    end
end

R2=(regexp(text, '(?<num>\d+)', 'names'));

m=1;

for i=1:length(R2)
    m=max(m, length(R2{i}));
end

tmp=[];
for i=1:length(R2)
    for j=1:m

        if j<=length(R2{i})
            tmp(i,j)=str2double(R2{i}(j).num);
        else
            tmp(i,j)=0;
        end

    end
end
tmp=sortrows(tmp);
newText=[];
for i=1:length(tmp)
    newText{i,1}=zef_dataBank_number2hash(tmp(i,:));
end

if isstruct(tree)
    tree=orderfields(tree, newText);
end

end
