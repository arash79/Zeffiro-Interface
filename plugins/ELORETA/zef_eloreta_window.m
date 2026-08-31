function zef = zef_eloreta_window(zef)
%ZEF_ELORETA_WINDOW  Build the eLORETA class-inverter dialog.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_eloreta_start, zef_open_class_inverse.

if nargin == 0
    zef = evalin('base', 'zef');
end

spec = struct();
spec.method_id = "eloreta";
spec.title = 'eLORETA';
spec.method_fields = { ...
    struct('name', 'regularization_parameter', 'label', 'Regularization α (empty = from SNR)', ...
        'kind', 'numeric', 'value', [], 'items', {{}}, 'scope', 'method'), ...
    struct('name', 'n_max_iterations', 'label', 'Max iterations', ...
        'kind', 'numeric', 'value', 200, 'items', {{}}, 'scope', 'method'), ...
    struct('name', 'convergence_tolerance', 'label', 'Convergence tolerance', ...
        'kind', 'numeric', 'value', 1e-6, 'items', {{}}, 'scope', 'method'), ...
    struct('name', 'apply_average_reference', 'label', 'Average-reference H', ...
        'kind', 'checkbox', 'value', true, 'items', {{}}, 'scope', 'method')};

zef = zef_open_class_inverse(zef, spec);

end
