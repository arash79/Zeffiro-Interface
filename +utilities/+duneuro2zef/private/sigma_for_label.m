function s = sigma_for_label(conductivity, lab, labels, idx)
%SIGMA_FOR_LABEL  Scalar conductivity for one DUNEuro tissue id.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    s = 0.33;
    if isempty(conductivity)
        return
    end
    if numel(conductivity) == numel(labels)
        s = conductivity(idx);
        return
    end
    if lab >= 1 && lab <= numel(conductivity)
        s = conductivity(lab);
        return
    end
    if lab >= 0 && (lab + 1) <= numel(conductivity)
        s = conductivity(lab + 1);
    end
end
