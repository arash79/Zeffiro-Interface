function zef =  zef_check_curvature_range(zef)
%ZEF_CHECK_CURVATURE_RANGE  Clamp the ROI curvature edit box to [-1, 1].
%
%   zef = zef_check_curvature_range(zef)
%
%   Reads zef.h_synth_source_ROI_curvature.String. Non-numeric → 0.
%   Values below -1 or above 1 are clipped and a warning is issued.
%   Writes the clamped number back onto the edit box. Does not copy the
%   value onto zef.synth_source_ROI; call zef_update_fss_ROI for that.
%
%   See also zef_disable_box_ROIsource, zef_update_fss_ROI.

editBox = zef.h_synth_source_ROI_curvature;

value = str2double(editBox.String);

if isnan(value) 
    value = 0; 
elseif value < -1 
    value = -1;
    warning('Curvature value was set to -1. Must be between -1 and 1.')
elseif value > 1
    value = 1;
    warning('Curvature value was set to 1. Must be between -1 and 1.')
end

set(editBox, 'String', num2str(value));

end