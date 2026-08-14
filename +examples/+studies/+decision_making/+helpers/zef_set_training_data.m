%ZEF_SET_TRAINING_DATA  Copy one training trial onto reconstruction databank nodes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Hard-codes data_ind=1, snr_ind=1, frame_number=1 and
%   load(<this +helpers folder>/data/training_dataset_p1_10dB.mat)
%   expecting variable training_data. Walks zef.dataBank.tree: each node
%   with type 'reconstruction' gets
%   training_data.z_inverse_results{1}{1}{rec_ind} at that frame.
%   Sets zef.resection_points from training_data.dipole_positions{1}{1}.
%   That data/ file is not in the repo; place it beside this helper.
%
%   See also zef_create_training_data_focal_epilepsy.

data_ind = 1;
snr_ind = 1;
frame_number = 1;

file_name = 'training_dataset_p1_10dB.mat';
folder_name = [fileparts(mfilename('fullpath')) filesep 'data'];
file_name = [folder_name filesep file_name];

load(file_name)
;

data_tree = zef.dataBank.tree;
rec_ind = 1;

fn = fieldnames(data_tree);
for k=1:numel(fn)
    node = data_tree.(fn{k});
    if (strcmp(node.type, 'custom'))
        data_type = node.name;
    end
    if (strcmp(node.type, 'reconstruction'))
        zef.dataBank.tree.(fn{k}).data.reconstruction{frame_number} = training_data.z_inverse_results{data_ind}{snr_ind}{rec_ind};
        rec_ind = rec_ind + 1;
    end
end

zef.resection_points = training_data.dipole_positions{data_ind}{snr_ind};
