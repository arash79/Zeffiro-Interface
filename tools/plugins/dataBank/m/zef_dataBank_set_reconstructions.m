function zef = zef_dataBank_set_reconstructions(zef,rec_cell,frame_number)
% --- Zeffiro documentation header ---
% zef_dataBank_set_reconstructions — Zef data Bank set reconstructions.
%
% Purpose:
%   Zef data Bank set reconstructions.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   rec_cell
%   frame_number
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_set_reconstructions
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_set_reconstructions(zef, rec_cell, frame_number)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
