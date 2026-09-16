function [L, info] = convert_leadfield(raw_lf, n_electrodes, modality)
%CONVERT_LEADFIELD  Map a DUNEuro/FieldTrip lead field onto Zeffiro zef.L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    if ~isnumeric(raw_lf) || isempty(raw_lf)
        error('duneuro2zef:InvalidLeadField', 'Lead field must be a nonempty numeric array.');
    end
    if ~isreal(raw_lf) || ~all(isfinite(raw_lf(:)))
        error('duneuro2zef:InvalidLeadField', 'Lead field must be real and finite.');
    end

    sz = size(raw_lf);
    if numel(sz) > 3
        error('duneuro2zef:InvalidLeadField', ...
            'Lead field has %d dimensions; expected 2-D or 3-D.', numel(sz));
    end

    if numel(sz) == 3 && sz(3) > 1
        L = lf_from_3d(raw_lf, n_electrodes);
    else
        L = lf_from_2d(raw_lf, n_electrodes);
    end

    info = struct();
    info.n_sensors = size(L, 1);
    info.layout = 'sensors x 3*sources, interleaved xyz per source';
    info.lead_field_type = 1;
    info.imaging_method = 1;
    if strcmp(modality, 'MEG')
        info.lead_field_type = 2;
        info.imaging_method = 2;
    end

    if mod(size(L, 2), 3) == 0
        info.n_sources = size(L, 2) / 3;
    elseif strcmp(modality, 'MEG')
        info.n_sources = size(L, 2);
        info.layout = 'sensors x sources (oriented MEG columns)';
    else
        error('duneuro2zef:InvalidLeadField', ...
            ['EEG lead-field columns (%d) are not a multiple of 3. ' ...
            'DUNEuro Cartesian dipoles are stored as xyz triplets per source.'], size(L, 2));
    end
end

function L = lf_from_2d(lf, n_electrodes)
    a = size(lf, 1);
    b = size(lf, 2);
    if ~isempty(n_electrodes) && n_electrodes > 0
        if a == n_electrodes
            L = lf;
            return
        end
        if b == n_electrodes && a ~= n_electrodes
            % Documented DUNEuro/FieldTrip layout is sensors × 3N. This array
            % has sensors on the second dimension, so it is the transpose.
            L = lf.';
            return
        end
        error('duneuro2zef:SensorLeadFieldMismatch', ...
            '2-D lead field size %s does not match %d electrodes on either dimension.', ...
            mat2str(size(lf)), n_electrodes);
    end
    % No electrode count: FieldTrip/DUNEuro 2-D L is sensors (rows) × 3N.
    L = lf;
end

function L = lf_from_3d(lf, n_electrodes)
    sz = size(lf);
    elec_dim = unique_dim(sz, n_electrodes, 1);
    ori_dim = orientation_dim(sz, elec_dim);
    src_dim = setdiff(1:3, [elec_dim, ori_dim]);
    if numel(src_dim) ~= 1
        error('duneuro2zef:InvalidLeadField', ...
            'Cannot separate source and orientation axes in lead-field size %s.', mat2str(sz));
    end
    lf3 = permute(lf, [elec_dim, ori_dim, src_dim]);
    L = reshape(lf3, size(lf3, 1), []);
end

function dim = unique_dim(sz, value, fallback)
    dim = fallback;
    if isempty(value) || value <= 0
        if sz(1) ~= 3
            dim = 1;
        elseif sz(end) ~= 3
            dim = numel(sz);
        end
        return
    end
    hits = find(sz == value);
    if isempty(hits)
        error('duneuro2zef:SensorLeadFieldMismatch', ...
            '3-D lead field size %s does not contain electrode count %d.', mat2str(sz), value);
    end
    if numel(hits) == 1
        dim = hits;
        return
    end
    if sz(1) == value
        dim = 1;
    else
        error('duneuro2zef:InvalidLeadField', ...
            'Electrode count %d matches more than one lead-field dimension %s.', value, mat2str(sz));
    end
end

function ori_dim = orientation_dim(sz, elec_dim)
    remaining = setdiff(1:3, elec_dim);
    ori_hits = remaining(sz(remaining) == 3);
    if numel(ori_hits) == 1
        ori_dim = ori_hits;
        return
    end
    if isempty(ori_hits)
        error('duneuro2zef:InvalidLeadField', ...
            '3-D lead field has no orientation axis of length 3 (size %s).', mat2str(sz));
    end
    % n_sources == 3 as well as n_orientations. Prefer orientation last
    % (n_sensors, n_sources, 3); else orientation first (3, n_sources, n_sensors).
    if ismember(3, ori_hits)
        ori_dim = 3;
        return
    end
    ori_dim = ori_hits(1);
end
