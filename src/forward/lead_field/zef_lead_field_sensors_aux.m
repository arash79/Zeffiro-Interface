function sensors_aux = zef_lead_field_sensors_aux(lead_field_type, sensors, sensors_attached_volume)
%ZEF_LEAD_FIELD_SENSORS_AUX  Sensor argument for FEM cores (metres or CEM indices).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   FEM cores work in metres. Session xyz is typically millimetres.
%   CEM attachment tables are integer indices and must not be scaled.
%
%   Types 1,4,5,6,9,10 (EEG / EIT / TES, iso and anisotropic):
%     3-column sensors (PEM) → attached xyz / 1000.
%     otherwise (CEM)        → sensors_attached_volume unscaled.
%   Types 2,3,7,8 (MEG magnetometer / gradiometer, iso and anisotropic):
%     zef.sensors with columns 1:3 divided by 1000; extra columns kept.
%
%   sensors_aux = zef_lead_field_sensors_aux(lead_field_type, sensors, ...
%       sensors_attached_volume)
%
%   See also zef_lead_field_matrix.

arguments
    lead_field_type (1,1) {mustBeNumeric}
    sensors
    sensors_attached_volume
end

eeg_family = [1, 4, 5, 6, 9, 10];
meg_family = [2, 3, 7, 8];

if ismember(lead_field_type, eeg_family) && size(sensors, 2) == 3
    if isempty(sensors_attached_volume)
        error('zef_lead_field_sensors_aux:MissingAttachment', ...
            ['PEM EEG/EIT/TES (lead_field_type %g) needs ', ...
            'sensors_attached_volume (snapped xyz).'], lead_field_type);
    end
    sensors_aux = sensors_attached_volume(:, 1:3) / 1000;
elseif ismember(lead_field_type, meg_family)
    sensors_aux = sensors;
    if isempty(sensors_aux)
        error('zef_lead_field_sensors_aux:MissingMEGSensors', ...
            ['MEG (lead_field_type %g) needs zef.sensors; ', ...
            'do not pass the EEG attachment table.'], lead_field_type);
    end
    sensors_aux(:, 1:3) = sensors_aux(:, 1:3) / 1000;
else
    sensors_aux = sensors_attached_volume;
end

end
