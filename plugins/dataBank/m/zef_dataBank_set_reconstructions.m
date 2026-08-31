function zef = zef_dataBank_set_reconstructions(zef,rec_cell,frame_number)
%ZEF_DATABANK_SET_RECONSTRUCTIONS  Write reconstruction cells back onto matching tree nodes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Scripting helper complementary to get_reconstructions. Used by
%   zef_process_training_data_focal_epilepsy. Walks fieldnames of
%   zef.dataBank.tree and, for each type 'reconstruction', writes
%   rec_cell{rec_ind} into .data.reconstruction{frame_number} in that
%   same order. Does not refresh the uitree. Assumes rec_cell has as many
%   entries as reconstruction nodes (and the same order as get_).
%
%   zef = zef_dataBank_set_reconstructions(zef, rec_cell, frame_number)
%
%   Inputs
%     zef           - session with dataBank.tree.
%     rec_cell      - cell of reconstruction arrays, one per rec node.
%     frame_number  - index into each node's reconstruction cell.
%
%   Output
%     zef  - tree payloads updated (in-memory; disk files unchanged).
%
%   See also zef_dataBank_get_reconstructions.

data_tree = zef.dataBank.tree;
rec_ind = 1;

fn = fieldnames(data_tree);
for k=1:numel(fn)
    if (strcmp(zef.dataBank.tree.(fn{k}).type, 'reconstruction'))
        zef.dataBank.tree.(fn{k}).data.reconstruction{frame_number} = rec_cell{rec_ind};
        rec_ind = rec_ind + 1;
    end
end

end
