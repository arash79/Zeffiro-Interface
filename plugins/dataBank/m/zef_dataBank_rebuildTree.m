function [newtree] = zef_dataBank_rebuildTree(tree)
%ZEF_DATABANK_REBUILDTREE  Renumber sibling hashes so they are contiguous.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   After delete (and from hash2tree / importDataBank). Walks fieldnames in
%   the current order (call sortTree first). Depth of each hash is the
%   count of numeric tokens. Same depth → increment the last index; shallower
%   → pop the path and increment; deeper → append 1. First node becomes
%   node_1. Does not rewrite disk files (see rebuildTreeSaveFile).
%
%   newtree = zef_dataBank_rebuildTree(tree)
%
%   Inputs
%     tree  - struct whose fields are hashes (already sorted numerically).
%
%   Output
%     newtree  - same payloads with dense hashes and .hash updated.
%
%   See also zef_dataBank_sortTree, zef_dataBank_rebuildTreeSaveFile.

hashes=fieldnames(tree);
newtree=struct;


if ~isempty(hashes)

    newtree.(zef_dataBank_number2hash(1))=tree.(hashes{1});
    newtree.(zef_dataBank_number2hash(1)).hash=zef_dataBank_number2hash(1);

    index=1;
    for i=2:length(hashes)
        num=(regexp(hashes{i}, '(?<num>\d+)'));

        if length(num)==length(index)
            index(end)=index(end)+1;

        else
            if length(num)<length(index)
                index=index(1:length(num));
                index(end)=index(end)+1;

            else
                index(end+1)=1;
            end
        end

        newtree.(zef_dataBank_number2hash(index))=tree.(hashes{i});
        newtree.(zef_dataBank_number2hash(index)).hash=zef_dataBank_number2hash(index);

    end

end

end
