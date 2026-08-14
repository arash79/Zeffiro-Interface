function [z] = zef_normalizeInverseReconstruction(z)
%ZEF_NORMALIZEINVERSERECONSTRUCTION  Scale reconstruction cell array to unit peak norm.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the maximum per-source vector magnitude across all frames (assuming
%   each frame stores [x; y; z] components interleaved in groups of three),
%   then divides every frame by that scalar.
%
%   z = zef_normalizeInverseReconstruction(z)
%
%   Input
%     z - cell array of reconstruction vectors (one cell per frame).
%
%   Output
%     z - same cell array, peak-normalized in place.
%
%   See also zef_process_inversion, zef_postProcessInverseClassObj.

    aux_norm_vec = 0;
    for f_ind = 1 : length(z)
        aux_norm_vec = max(sqrt(sum(reshape(z{f_ind}, 3, length(z{f_ind})/3).^2)),aux_norm_vec);
    end
    for f_ind = 1 : length(z)
        z{f_ind} = z{f_ind}./max(aux_norm_vec);
    end

end
