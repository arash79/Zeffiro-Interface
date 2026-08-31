function zef = zef_dipole_window(zef)
%ZEF_DIPOLE_WINDOW  Construct the Dipole Scan App Designer window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_dipole_window(zef)
%
%   Called from zef_dipole_start (INI: Inverse tools → Dipole Scan).
%   Instantiates dipole_app, sets the window title, and assigns
%   StartButton.ButtonPushedFcn to zef_dipoleScan. Does not invert.
%   Menu row is Dipole Scan, inverse_tools, zef_dipole_start.
%
%   See also zef_dipole_start, zef_dipoleScan.
%

zef.dipole_app = dipole_app;
appName='dipole_app';

zef.dipole_app.ZEFFIROInterfaceDipoleScanUIFigure.Name = 'ZEFFIRO Interface: Dipole scan tool';

%Import or set initial values

zef.inv_names={'inv_leadfield_lambda', 'inv_snr', 'inv_sampling_frequency', 'inv_low_cut_frequency',...
    'inv_high_cut_frequency', 'inv_time_1', 'inv_time_2', 'number_of_frames', 'inv_time_3', 'inv_data_segment'...
    'normalize_leadfield', 'L_reg_type'};
zef.inv_default={1e-3, 30, 2400, 2, 80, 0, 0, 0, 0, 1, 1, 1};
for invNames=1:length(zef.inv_names)
    if ~isfield(zef,zef.inv_names{invNames})
        zef.(zef.inv_names{invNames})=zef.inv_default{invNames};
    end
end

zef_props = properties(zef.(appName));
for zef_i = 1:length(zef_props)
    if isfield(zef,zef_props{zef_i})
        try
            zef.(appName).(zef_props{zef_i}).Value = zef_ui_num2str(zef.(zef_props{zef_i}));
        catch
        end
    end
end
clear zef_props zef_i

zef.dipole_app.dipole_type.ValueChangedFcn = 'zef.dipole_type = str2num(zef.dipole_app.dipole_type.Value);';
zef.dipole_app.inv_snr.ValueChangedFcn = 'zef.inv_snr = str2num(zef.dipole_app.inv_snr.Value);';
zef.dipole_app.inv_sampling_frequency.ValueChangedFcn = 'zef.inv_sampling_frequency = str2num(zef.dipole_app.inv_sampling_frequency.Value);';
zef.dipole_app.inv_low_cut_frequency.ValueChangedFcn = 'zef.inv_low_cut_frequency = str2num(zef.dipole_app.inv_low_cut_frequency.Value);';
zef.dipole_app.inv_high_cut_frequency.ValueChangedFcn = 'zef.inv_high_cut_frequency = str2num(zef.dipole_app.inv_high_cut_frequency.Value);';
zef.dipole_app.inv_time_1.ValueChangedFcn = 'zef.inv_time_1 = str2num(zef.dipole_app.inv_time_1.Value);';
zef.dipole_app.inv_time_2.ValueChangedFcn = 'zef.inv_time_2 = str2num(zef.dipole_app.inv_time_2.Value);';
zef.dipole_app.number_of_frames.ValueChangedFcn = 'zef.number_of_frames = str2num(zef.dipole_app.number_of_frames.Value);';
zef.dipole_app.inv_time_3.ValueChangedFcn = 'zef.inv_time_3 = str2num(zef.dipole_app.inv_time_3.Value);';
zef.dipole_app.inv_data_segment.ValueChangedFcn = 'zef.inv_data_segment = str2num(zef.dipole_app.inv_data_segment.Value);';
zef.dipole_app.normalize_data.ValueChangedFcn = 'zef.normalize_data = str2num(zef.dipole_app.normalize_data.Value);';
zef.dipole_app.normalize_leadfield.ValueChangedFcn = 'zef.normalize_leadfield = str2num(zef.dipole_app.normalize_leadfield.Value);';

zef.dipole_app.StartButton.ButtonPushedFcn = '[zef.reconstruction, zef.reconstruction_information]=zef_dipoleScan(zef);';
zef.dipole_app.CloseButton.ButtonPushedFcn = 'delete(zef.dipole_app);';

end
