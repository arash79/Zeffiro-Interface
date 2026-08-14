%MEAN_REC  Script: average all dataBank reconstructions frame-wise onto zef.reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef.dataBank.tree; writes zef.reconstruction as cell of means. Not
%   a Kalman-window callback.
%

z_inverse_results = cell(0);

data_tree = zef.dataBank.tree;
rec_ind = 1;
fn = fieldnames(data_tree);
for k=1:numel(fn)
    node = data_tree.(fn{k});
    if (strcmp(node.type, 'reconstruction'))
        rec = node.data.reconstruction;
        number_of_frames = length(rec);
        for i= 1:number_of_frames
            z_inverse_results{i}{rec_ind} = rec{i};
        end
        rec_ind = rec_ind + 1;
    end
end


z_mean = cell(0);
% average
for i = 1:size(z_inverse_results,2)
    z_mean{i} = mean([z_inverse_results{i}{:}],2);
end
zef.reconstruction = z_mean;
