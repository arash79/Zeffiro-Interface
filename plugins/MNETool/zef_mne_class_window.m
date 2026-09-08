function zef = zef_mne_class_window(zef)
%ZEF_MNE_CLASS_WINDOW  Build the MNE class-inverter dialog.
%
%   Zeffiro Interface.
%   Copyright 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_mne_class_start, zef_open_class_inverse, inverse.MNEInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

spec = struct();
spec.method_id = "mne";
spec.title = 'MNE';
spec.method_fields = { ...
    struct('name', 'initial_prior_steering_db', 'label', 'Initial prior steering (dB)', ...
        'kind', 'numeric', 'value', 0, 'items', {{}}, 'scope', 'method')};

zef = zef_open_class_inverse(zef, spec);

end
