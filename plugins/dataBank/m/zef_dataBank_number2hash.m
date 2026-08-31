function [hash]=zef_dataBank_number2hash(number)
%ZEF_DATABANK_NUMBER2HASH  Join an integer path as node_i_j_k.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Hash helper used by add/rebuild/sort/import. Starts at 'node' and
%   appends '_n' for each entry of number that is not 0 or NaN (sortTree
%   pads shorter paths with 0). Empty or all-zero number → 'node'.
%   No zef fields.
%
%   hash = zef_dataBank_number2hash(number)
%
%   Inputs
%     number  - 1-by-d vector of path indices, e.g. [1 2] → 'node_1_2'.
%
%   Output
%     hash  - char field name.
%
%   See also zef_dataBank_sortTree, zef_dataBank_rebuildTree.

%x is an array of numbers; append _k for each nonzero, non-NaN entry.
hash='node';
for i=1:length(number)
    if ~isnan(number(i)) && ~number(i)==0
        hash=strcat(hash, '_', num2str(number(i)));
    end
end

end
