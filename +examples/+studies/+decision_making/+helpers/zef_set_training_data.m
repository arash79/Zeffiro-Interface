% --- Zeffiro documentation header ---
% examples.studies.decision_making.helpers.data_ind = 1; — Example or study script demonstrating data_ind = 1;.
%
% Purpose:
%   Example or study script demonstrating data_ind = 1;.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Zef fields (observed):
%   zef.dataBank (read)
%   zef.resection_points (read, write)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.studies.decision_making.helpers.data_ind = 1;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

data_ind = 1;
snr_ind = 1;
frame_number = 1;

file_name = 'training_dataset_p1_10dB.mat';
folder_name = [fileparts(mfilename('fullpath')) filesep 'data'];
file_name = [folder_name filesep file_name];

load(file_name);

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
