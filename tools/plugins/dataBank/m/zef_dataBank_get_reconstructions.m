function [rec_cell, rec_info] = zef_dataBank_get_reconstructions(zef,frame_number)
% --- Zeffiro documentation header ---
% zef_dataBank_get_reconstructions — Zef data Bank get reconstructions.
%
% Purpose:
%   Zef data Bank get reconstructions.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   frame_number
%
% Outputs:
%   rec_cell
%   rec_info
%
% Zef fields (observed):
%   zef.dataBank (read)
%   zef.reconstruction (read, write)
%
% Calls (project):
%   zef_dataBank_get_reconstructions
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[rec_cell, rec_info]] = zef_dataBank_get_reconstructions(zef, frame_number)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
