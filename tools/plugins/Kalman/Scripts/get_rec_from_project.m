% --- Zeffiro documentation header ---
% z_inverse_results = cell(0); — Z inverse results = cell(0);.
%
% Purpose:
%   Z inverse results = cell(0);.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.dataBank (read)
%   zef.h_parcellation_interpolation (read)
%   zef.h_parcellation_list (read)
%   zef.h_parcellation_plot_type (read)
%   zef.h_time_series_tools_list (read)
%   zef.parcellation_interp_ind (read)
%   zef.parcellation_selected (read, write)
%   zef.parcellation_time_series (read, write)
%   zef.reconstruction (read, write)
%
% Calls (project):
%   zef_parcellation_interpolation
%   zef_parcellation_time_series
%   zef_plot_parcellation_time_series
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `z_inverse_results = cell(0);` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
    zef.h_parcellation_list.Value = [23, 77];
    zef.parcellation_selected = get(zef.h_parcellation_list,'value');


    [zef.parcellation_interp_ind] = zef_parcellation_interpolation(zef); zef_update_parcellation; set(zef.h_parcellation_interpolation,'foregroundcolor',[0 0 0]);

    zef.h_parcellation_plot_type.Value = 20;
    zef.h_time_series_tools_list.Value = 21;
    
    zef.parcellation_time_series = zef_parcellation_time_series([]);
    zef_plot_parcellation_time_series([]);

    savefig(fullfile(['figures/rec_',num2str(i),'.fig']))
    i = i + 1;
end
