function validate_payload(payload)
%VALIDATE_PAYLOAD  Require a usable payload, then check L / sensors / mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    require_something(payload);
    consistency_checks(payload);
end

function require_something(payload)
    has_l = ~isempty(payload.L);
    has_mesh = ~isempty(payload.nodes);
    has_sens = ~isempty(payload.sensors);
    if ~(has_l || has_mesh || has_sens)
        error('duneuro2zef:EmptyProject', ...
            ['This file has no lead field, mesh, or electrodes that Zeffiro can use. ' ...
            'A DUNEuro transfer matrix alone is not a Zeffiro project.']);
    end
end

function consistency_checks(payload)
    if ~isempty(payload.L)
        if ~all(isfinite(payload.L(:)))
            error('duneuro2zef:InvalidLeadField', 'Converted lead field contains non-finite values.');
        end
        if size(payload.L, 1) < 1 || size(payload.L, 2) < 1
            error('duneuro2zef:InvalidLeadField', 'Converted lead field is empty.');
        end
    end
    if ~isempty(payload.sensors) && ~isempty(payload.L)
        if size(payload.L, 1) ~= size(payload.sensors, 1)
            error('duneuro2zef:SensorLeadFieldMismatch', ...
                'Internal error: L rows (%d) != electrodes (%d).', ...
                size(payload.L, 1), size(payload.sensors, 1));
        end
    end
    if ~isempty(payload.tetra)
        if size(payload.tetra, 2) ~= 4
            error('duneuro2zef:InvalidMesh', 'Tetrahedra must be N×4.');
        end
        if max(payload.tetra(:)) > size(payload.nodes, 1)
            error('duneuro2zef:InvalidMesh', 'Tetrahedron index exceeds node count.');
        end
        if numel(payload.domain_labels) ~= size(payload.tetra, 1)
            error('duneuro2zef:InvalidMesh', 'domain_labels length does not match tetra count.');
        end
    end
end
