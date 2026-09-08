function zef = zef_csm_class_window(zef)
%ZEF_CSM_CLASS_WINDOW  Build the CSM class-inverter dialog.
%
%   Zeffiro Interface.
%   Copyright 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_csm_class_start, zef_open_class_inverse, inverse.CSMInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

spec = struct();
spec.method_id = "csm";
spec.title = 'CSM';
spec.method_fields = { ...
    struct('name', 'method_type', 'label', 'Method type', ...
        'kind', 'dropdown', 'value', 'dSPM', ...
        'items', {{'dSPM', 'sLORETA', 'sLORETA 3D', 'SBL'}}, 'scope', 'method'), ...
    struct('name', 'SBL_number_of_iterations', 'label', 'SBL iterations', ...
        'kind', 'numeric', 'value', 1, 'items', {{}}, 'scope', 'method'), ...
    struct('name', 'theta0', 'label', 'Prior variance θ₀', ...
        'kind', 'numeric', 'value', 1e-3, 'items', {{}}, 'scope', 'method')};

zef = zef_open_class_inverse(zef, spec);

end
