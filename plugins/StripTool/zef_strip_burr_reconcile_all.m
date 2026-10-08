function [zef, dropped] = zef_strip_burr_reconcile_all(zef)
%ZEF_STRIP_BURR_RECONCILE_ALL  Reconcile every sensor strip cell in the session.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [zef, dropped] = zef_strip_burr_reconcile_all(zef)
%
%   See also zef_strip_burr_reconcile.

dropped = cell(1, 0);
if ~isstruct(zef)
    return
end
names = fieldnames(zef);
for i = 1:numel(names)
    if ~endsWith(names{i}, '_strip_cell') || ~iscell(zef.(names{i}))
        continue
    end
    cell_aux = zef.(names{i});
    for j = 1:numel(cell_aux)
        if ~isstruct(cell_aux{j}) || ~isscalar(cell_aux{j})
            continue
        end
        if ~isfield(cell_aux{j}, 'burr_holes')
            continue
        end
        [holes, gone] = zef_strip_burr_reconcile(zef, cell_aux{j}.burr_holes);
        cell_aux{j}.burr_holes = holes;
        if ~isempty(gone)
            dropped = [dropped, gone]; %#ok<AGROW>
        end
    end
    zef.(names{i}) = cell_aux;
end

end
