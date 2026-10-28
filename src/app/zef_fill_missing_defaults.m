function zef = zef_fill_missing_defaults(zef)
%ZEF_FILL_MISSING_DEFAULTS  Copy catalog defaults onto fields zef does not have.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_fill_missing_defaults(zef)
%
%   Existing values are left alone, including lead fields, meshes, and
%   file paths. zef.font_size is required because the catalog copies it.
%   Does not reseed compartments, sensors, or profiles; zef_init does
%   that at startup only.
%
%   See also zef_session_defaults, zef_init, zef_load.

if nargin < 1 || ~isstruct(zef) || ~isfield(zef, 'font_size')
    error('zef_fill_missing_defaults:MissingFontSize', ...
        'zef.font_size is required before session defaults can be applied.');
end

% Match the historical zef_init name list: fieldnames is recorded before
% the catalog is applied, so a session that did not already have that
% scratch field does not list the name 'fieldnames' inside it.
zef.fieldnames = fieldnames(zef);
defaults = struct();
for i = 1:numel(zef.fieldnames)
    defaults.(zef.fieldnames{i}) = zef.(zef.fieldnames{i});
end

catalog = zef_session_defaults(zef);
catalog_names = fieldnames(catalog);
for i = 1:numel(catalog_names)
    defaults.(catalog_names{i}) = catalog.(catalog_names{i});
end

zef.fieldnames = fieldnames(defaults);
for i = 1:numel(zef.fieldnames)
    name = zef.fieldnames{i};
    if ~isfield(zef, name)
        zef.(name) = defaults.(name);
    end
end

end
