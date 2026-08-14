%GET_REC_FROM_PROJECT  Script: plot parcellation time series for every dataBank reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks zef.dataBank.tree reconstruction nodes, sets zef.reconstruction,
%   opens zef_parcellation_tool, and savefig figures/rec_*.fig. Not a menu
%   button.
%

z_inverse_results = cell(0);

data_tree = zef.dataBank.tree;
rec_ind = 1;
fn = fieldnames(data_tree);
for k=1:numel(fn)
    node = data_tree.(fn{k});
    if (strcmp(node.type, 'reconstruction'))
        rec = node.data.reconstruction;
        z_inverse_results{rec_ind} = rec;
        rec_ind = rec_ind + 1;
    end
end

zef_parcellation_tool;
zef_update;
i = 1;
for rec = z_inverse_results
    zef.reconstruction = rec{1};
    

    
    % Take sg006 and lh023
    zef_colored_list('value', zef.h_parcellation_list, [23, 77]);
    zef.parcellation_selected = zef_colored_list('value', zef.h_parcellation_list);


    [zef.parcellation_interp_ind] = zef_parcellation_interpolation(zef); zef_update_parcellation; set(zef.h_parcellation_interpolation,'foregroundcolor',[0 0 0]);

    zef.h_parcellation_plot_type.Value = 20;
    zef.h_time_series_tools_list.Value = 21;
    
    zef.parcellation_time_series = zef_parcellation_time_series([]);
    zef_plot_parcellation_time_series([]);

    savefig(fullfile(['figures/rec_',num2str(i),'.fig']))
    i = i + 1;
end
