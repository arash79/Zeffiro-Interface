function [z] = zef_normalizeInverseReconstruction(z)
% --- Zeffiro documentation header ---
% zef_normalizeInverseReconstruction — Zef normalize Inverse Reconstruction.
%
% Purpose:
%   Zef normalize Inverse Reconstruction.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   z
%
% Outputs:
%   z
%
% Calls (project):
%   zef_normalizeInverseReconstruction
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[z] = zef_normalizeInverseReconstruction(z)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    aux_norm_vec = 0;
    for f_ind = 1 : length(z)
        aux_norm_vec = max(sqrt(sum(reshape(z{f_ind}, 3, length(z{f_ind})/3).^2)),aux_norm_vec);
    end
    for f_ind = 1 : length(z)
        z{f_ind} = z{f_ind}./max(aux_norm_vec);
    end

end
