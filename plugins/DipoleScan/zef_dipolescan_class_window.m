function zef = zef_dipolescan_class_window(zef)
%ZEF_DIPOLESCAN_CLASS_WINDOW  Build the Dipole Scan class-inverter dialog.
%
%   Zeffiro Interface.
%   Copyright 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_dipolescan_class_start, zef_open_class_inverse, inverse.DipoleScanInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

spec = struct();
spec.method_id = "dipolescan";
spec.title = 'Dipole Scan';
spec.method_fields = { ...
    struct('name', 'method_type', 'label', 'Inversion method', ...
        'kind', 'dropdown', 'value', 'SVD', ...
        'items', {{'SVD', 'Pseudoinverse'}}, 'scope', 'method'), ...
    struct('name', 'reg_type', 'label', 'Regularization type', ...
        'kind', 'dropdown', 'value', 'None', ...
        'items', {{'None', 'Basic'}}, 'scope', 'method'), ...
    struct('name', 'reg_parameter', 'label', 'Regularization parameter', ...
        'kind', 'numeric', 'value', 0.001, 'items', {{}}, 'scope', 'method')};

zef = zef_open_class_inverse(zef, spec);

end
