function zef = zef_dti_conductivity_update_conversion_model(zef)
%ZEF_DTI_CONDUCTIVITY_UPDATE_CONVERSION_MODEL  Copy conversion widgets into zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ValueChangedFcn for the DTI Conductivity Tool conversion panel. Copies
%   volume fraction, extra/intra conductivity, scale, anisotropy threshold,
%   and model dropdown onto zef.dti_* fields. Does not interpolate or
%   rewrite zef.sigma; those happen on **Apply to Mesh**.
%
%   Missing or invalid handles are skipped. nargout==0 → assignin base zef.
%
%   See also zef_dti_apply_to_sigma, zef_dti_conductivity_window.

if nargin == 0
    zef = evalin('base','zef');
end
if isfield(zef,'h_dti_volume_fraction') && isvalid(zef.h_dti_volume_fraction)
    zef.dti_volume_fraction = zef.h_dti_volume_fraction.Value;
end
if isfield(zef,'h_dti_extra_conductivity') && isvalid(zef.h_dti_extra_conductivity)
    zef.dti_extra_conductivity = zef.h_dti_extra_conductivity.Value;
end
if isfield(zef,'h_dti_intra_conductivity') && isvalid(zef.h_dti_intra_conductivity)
    zef.dti_intra_conductivity = zef.h_dti_intra_conductivity.Value;
end
if isfield(zef,'h_dti_conductivity_scale') && isvalid(zef.h_dti_conductivity_scale)
    zef.dti_conductivity_scale = zef.h_dti_conductivity_scale.Value;
end
if isfield(zef,'h_dti_anisotropy_threshold') && isvalid(zef.h_dti_anisotropy_threshold)
    zef.dti_anisotropy_threshold = zef.h_dti_anisotropy_threshold.Value;
end
if isfield(zef,'h_dti_model_dropdown') && isvalid(zef.h_dti_model_dropdown)
    zef.dti_conductivity_model = zef.h_dti_model_dropdown.Value;
end
if nargout == 0
    assignin('base','zef',zef);
end

end
