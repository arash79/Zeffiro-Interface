% --- Zeffiro documentation header ---
% z_inverse_results = cell(0); — Z inverse results = cell(0);.
%
% Purpose:
%   Z inverse results = cell(0);.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.dataBank (read)
%   zef.reconstruction (read, write)
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
