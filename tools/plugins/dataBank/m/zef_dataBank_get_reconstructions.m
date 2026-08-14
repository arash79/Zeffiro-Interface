function [rec_cell, rec_info] = zef_dataBank_get_reconstructions(zef,frame_number)
%ZEF_DATABANK_GET_RECONSTRUCTIONS  Collect one frame from every reconstruction node.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Scripting helper (not a button). Used by the decision-making examples
%   (zef_create_training_data_focal_epilepsy, zef_decision_script_focal_epilepsy)
%   after zef_start_dataBank. Walks fieldnames of zef.dataBank.tree in
%   order: a custom node sets data_type to that node's .name; each
%   reconstruction node appends reconstruction{frame_number} and
%   {data_type, rec_name}. Also sets zef.reconstruction = cell(0) (side
%   effect; the returned zef is not written back). frame_number defaults to 1.
%
%   [rec_cell, rec_info] = zef_dataBank_get_reconstructions(zef)
%   [rec_cell, rec_info] = zef_dataBank_get_reconstructions(zef, frame_number)
%
%   Inputs
%     zef           - session with dataBank.tree (custom parents + rec children).
%     frame_number  - index into each node's reconstruction cell (default 1).
%
%   Output
%     rec_cell  - 1-by-n cell of reconstruction arrays for that frame.
%     rec_info  - n-by-2 cell: {custom parent name, reconstruction node name}.
%
%   See also zef_dataBank_set_reconstructions.

if nargin < 2
    frame_number = 1;
end

rec_cell = cell(0);
rec_info = cell(0);
zef.reconstruction = cell(0);

data_tree = zef.dataBank.tree;
rec_ind = 1;

fn = fieldnames(data_tree);
for k=1:numel(fn)
    node = data_tree.(fn{k});
    if (strcmp(node.type, 'custom'))
        data_type = node.name;
    end
    if (strcmp(node.type, 'reconstruction'))
        rec_name = node.name;
        rec = node.data.reconstruction;
        rec_cell{rec_ind} = rec{frame_number};
        rec_info(rec_ind,:) = [{data_type}  {rec_name}];
        rec_ind = rec_ind + 1;
    end
end

end
