function [pos, dir, model] = convert_sources(raw)
%CONVERT_SOURCES  Source positions, directions, and model from DUNEuro.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    pos = [];
    dir = [];
    model = [];
    dipoles = find_named(raw, {'dipoles', 'dipole'}, 2);
    if ~isempty(dipoles) && isnumeric(dipoles)
        if size(dipoles, 1) == 6
            pos = dipoles(1:3, :).';
            dir = dipoles(4:6, :).';
        elseif size(dipoles, 2) == 6
            pos = dipoles(:, 1:3);
            dir = dipoles(:, 4:6);
        elseif size(dipoles, 2) == 3
            pos = dipoles;
        elseif size(dipoles, 1) == 3
            pos = dipoles.';
        end
    end
    if isempty(pos)
        val = find_named(raw, {'source_positions', 'source_grid', 'sourcepos'}, 2);
        if ~isempty(val) && isnumeric(val)
            pos = as_n_by_k(val, 3, 'source positions');
        end
    end
    if ~isempty(pos) && ~all(isfinite(pos(:)))
        error('duneuro2zef:InvalidSources', 'Source coordinates contain non-finite values.');
    end

    sm = find_named(raw, {'source_model'}, 3);
    if isstruct(sm) && isfield(sm, 'type')
        sm = sm.type;
    end
    if ~isempty(sm)
        model = map_source_model(sm);
    end
end

function model = map_source_model(sm)
    model = [];
    key = lower(strtrim(char(string(sm))));
    key = strrep(strrep(strrep(key, ' ', ''), '.', ''), '_', '');
    switch key
        case {'whitney', '1'}
            model = core.types.ZefSourceModel.Whitney;
        case {'hdiv', 'h(div)', '2'}
            model = core.types.ZefSourceModel.Hdiv;
        case {'venant', 'stvenant', 'saintvenant', '3'}
            model = core.types.ZefSourceModel.StVenant;
        case {'continuouswhitney', '4'}
            model = core.types.ZefSourceModel.ContinuousWhitney;
        case {'continuoushdiv', '5'}
            model = core.types.ZefSourceModel.ContinuousHdiv;
        case {'continuousstvenant', '6'}
            model = core.types.ZefSourceModel.ContinuousStVenant;
        otherwise
            model = [];
    end
end
