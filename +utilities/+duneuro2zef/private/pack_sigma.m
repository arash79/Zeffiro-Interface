function [sigma, report] = pack_sigma(payload, conductivity, tensors, hex_converted, report)
%PACK_SIGMA  Per-tetra conductivity (and optional anisotropy) for Zeffiro.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    n_tet = size(payload.tetra, 1);
    sigma = zeros(n_tet, 1);
    labels = payload.domain_labels;
    orig = [];
    if isfield(payload, 'duneuro_import') && isfield(payload.duneuro_import, 'original_tissue_ids')
        orig = payload.duneuro_import.original_tissue_ids;
    end

    if ~isempty(conductivity) && numel(conductivity) == n_tet
        sigma(:, 1) = conductivity(:);
    elseif hex_converted && ~isempty(conductivity) && numel(conductivity) * 6 == n_tet
        sigma(:, 1) = repelem(conductivity(:), 6);
    else
        uniq = unique(labels);
        for i = 1:numel(uniq)
            lab = uniq(i);
            mask = labels == lab;
            orig_lab = lab;
            if numel(orig) >= i
                orig_lab = orig(i);
            end
            sigma(mask, 1) = sigma_for_label(conductivity, orig_lab, orig, i);
        end
    end

    if isempty(tensors)
        return
    end
    if size(tensors, 1) ~= n_tet && hex_converted && size(tensors, 1) * 6 == n_tet
        tensors = repelem(tensors, 6, 1);
    end
    if size(tensors, 1) ~= n_tet
        report.warnings{end+1} = sprintf( ...
            'Anisotropic tensors (%d rows) do not match %d tetrahedra; tensors were not applied.', ...
            size(tensors, 1), n_tet);
        return
    end
    packed = pack_tensor_rows(tensors);
    sigma = [sigma, zeros(n_tet, 1), packed];
end

function packed = pack_tensor_rows(tensors)
    % Zeffiro anisotropic columns are [σ11 σ22 σ33 σ12 σ13 σ23].
    % DUNEuro / SimBio 6-vectors are xx yy zz xy xz yz. 9-vectors are
    % row-major 3×3 (xx xy xz yx yy yz zx zy zz).
    if size(tensors, 2) == 6
        packed = tensors;
        return
    end
    if size(tensors, 2) == 9
        packed = tensors(:, [1, 5, 9, 2, 3, 6]);
        return
    end
    error('duneuro2zef:InvalidConductivity', ...
        'Conductivity tensors must have 6 or 9 columns, got %d.', size(tensors, 2));
end
