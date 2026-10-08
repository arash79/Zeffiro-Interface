function catalog = zef_strip_burr_catalog(zef)
%ZEF_STRIP_BURR_CATALOG  Compartments actually present, with mesh domain ids.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks zef.compartment_tags in order. Names, on/off state, and scalar
%   conductivity are read from zef.<tag>_*. The domain label is the index
%   among compartments with _on true, which is the id zef_postprocess_fem_mesh
%   stores in zef.domain_labels and zef.sigma(:,2). A compartment that is
%   off has domain_label NaN. Nothing here assumes an anatomical name or a
%   fixed tag number.
%
%   catalog = zef_strip_burr_catalog(zef)
%
%   See also zef_strip_burr_pick, zef_postprocess_fem_mesh.

catalog.tag = {};
catalog.name = {};
catalog.on = false(0, 1);
catalog.sigma = zeros(0, 1);
catalog.domain_label = zeros(0, 1);

if ~isstruct(zef) || ~isfield(zef, 'compartment_tags') || isempty(zef.compartment_tags)
    return
end
tags = zef.compartment_tags;
if isstring(tags)
    tags = cellstr(tags);
end
n = numel(tags);
catalog.tag = cell(1, n);
catalog.name = cell(1, n);
catalog.on = false(n, 1);
catalog.sigma = nan(n, 1);
catalog.domain_label = nan(n, 1);
active = 0;
for k = 1:n
    tag = char(string(tags{k}));
    catalog.tag{k} = tag;
    name = tag;
    name_field = [tag '_name'];
    if isfield(zef, name_field) && ~isempty(zef.(name_field))
        name = char(string(zef.(name_field)));
    end
    catalog.name{k} = strtrim(name);
    on_field = [tag '_on'];
    if isfield(zef, on_field) && ~isempty(zef.(on_field))
        on_val = double(zef.(on_field));
        catalog.on(k) = on_val(1) ~= 0;
    end
    sigma_field = [tag '_sigma'];
    if isfield(zef, sigma_field) && ~isempty(zef.(sigma_field))
        sig = double(zef.(sigma_field));
        if isscalar(sig) && isfinite(sig)
            catalog.sigma(k) = sig;
        end
    end
    if catalog.on(k)
        active = active + 1;
        catalog.domain_label(k) = active;
    end
end

end
