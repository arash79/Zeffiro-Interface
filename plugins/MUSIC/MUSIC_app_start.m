%MUSIC_APP_START  Open Inverse tools → MUSIC (MUSIC_app).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. INI callback in every default/asteroid profile. Constructs
%   MUSIC_app, fills type Items (1 source projection / 2 noise
%   out-projection) and L-reg Items (1 Basic / 2 Pseudoinverse). Default
%   MUSIC_leadfield_lambda 1e-3; copies inv_snr, band, inv_time_*,
%   number_of_frames, inv_data_segment from zef. Pseudoinverse disables
%   the lambda edit (ValueChangedFcn also tests type==3, which has no
%   Item). StartButton: zef.reconstruction = MUSIC_iteration (discards
%   Var_loc; no reconstruction_information). CloseButton deletes the app.
%   Needs zef.L and zef.measurements in base. No inverse.*Inverter.
%
%   See also MUSIC_iteration.

zef.MUSIC = MUSIC_app;

%_ Names of methods that are included in app _
zef_MUSIC_names = {'Source projection',
    'Noise out-projection'
    };

zef.MUSIC.MUSIC_type.Items = zef_MUSIC_names;
zef.MUSIC.MUSIC_type.ItemsData = strsplit(num2str(1:length(zef_MUSIC_names)));
zef.MUSIC.MUSIC_type.Value = '1';
if ~isfield(zef,'MUSIC_type')
    zef.MUSIC_type = 1;
end

%_ Names of leadfield regularization methods _
zef_MUSIC_names = {'Basic',
    'Pseudoinverse'};

zef.MUSIC.MUSIC_L_reg_type.Items = zef_MUSIC_names;
zef.MUSIC.MUSIC_L_reg_type.ItemsData = strsplit(num2str(1:length(zef_MUSIC_names)));
zef.MUSIC.MUSIC_L_reg_type.Value = '1';
if ~isfield(zef,'MUSIC_L_reg_type')
    zef.MUSIC_L_reg_type = 1;
end

%_ Initial values _
zef.MUSIC.MUSIC_leadfield_lambda.Value = '1e-3';
zef.MUSIC.inv_snr.Value = zef_ui_num2str(zef.inv_snr);
zef.MUSIC.inv_sampling_frequency.Value = zef_ui_num2str(zef.inv_sampling_frequency);
zef.MUSIC.inv_low_cut_frequency.Value = zef_ui_num2str(zef.inv_low_cut_frequency);
zef.MUSIC.inv_high_cut_frequency.Value = zef_ui_num2str(zef.inv_high_cut_frequency);
zef.MUSIC.inv_time_1.Value = zef_ui_num2str(zef.inv_time_1);
zef.MUSIC.inv_time_2.Value = zef_ui_num2str(zef.inv_time_2);
zef.MUSIC.number_of_frames.Value = zef_ui_num2str(zef.number_of_frames);
zef.MUSIC.inv_time_3.Value = zef_ui_num2str(zef.inv_time_3);
zef.MUSIC.inv_data_segment.Value = zef_ui_num2str(zef.inv_data_segment);

if ~isfield(zef,'MUSIC_leadfield_lambda')
    zef.MUSIC_leadfield_lambda = 1e-3;
end

%set parameters if saved in ZI:
%(Naming concept: zef.MUSIC."field" = zef."field")
zef_props = properties(zef.MUSIC);
for zef_i = 1:length(zef_props)
    if isfield(zef,zef_props{zef_i})
        try
            zef.MUSIC.(zef_props{zef_i}).Value = zef_ui_num2str(zef.(zef_props{zef_i}));
        catch
        end
    end
end
clear zef_props zef_i

if zef.MUSIC_L_reg_type==2
    zef.MUSIC.MUSIC_leadfield_lambda.Enable = 'off';
end

%_ Functions _
zef.MUSIC.MUSIC_type.ValueChangedFcn = 'zef.MUSIC_type = str2num(zef.MUSIC.MUSIC_type.Value);';
zef.MUSIC.MUSIC_leadfield_lambda.ValueChangedFcn = 'zef.MUSIC_leadfield_lambda = str2num(zef.MUSIC.MUSIC_leadfield_lambda.Value);';
zef.MUSIC.MUSIC_L_reg_type.ValueChangedFcn = 'zef.MUSIC_L_reg_type = str2num(zef.MUSIC.MUSIC_L_reg_type.Value); if zef.MUSIC_L_reg_type==2 || zef.MUSIC_L_reg_type==3; zef.MUSIC.MUSIC_leadfield_lambda.Enable = ''off''; else; zef.MUSIC.MUSIC_leadfield_lambda.Enable = ''on''; end;';
zef.MUSIC.inv_snr.ValueChangedFcn = 'zef.inv_snr = str2num(zef.MUSIC.inv_snr.Value);';
zef.MUSIC.inv_sampling_frequency.ValueChangedFcn = 'zef.inv_sampling_frequency = str2num(zef.MUSIC.inv_sampling_frequency.Value);';
zef.MUSIC.inv_low_cut_frequency.ValueChangedFcn = 'zef.inv_low_cut_frequency = str2num(zef.MUSIC.inv_low_cut_frequency.Value);';
zef.MUSIC.inv_high_cut_frequency.ValueChangedFcn = 'zef.inv_high_cut_frequency = str2num(zef.MUSIC.inv_high_cut_frequency.Value);';
zef.MUSIC.inv_time_1.ValueChangedFcn = 'zef.inv_time_1 = str2num(zef.MUSIC.inv_time_1.Value);';
zef.MUSIC.inv_time_2.ValueChangedFcn = 'zef.inv_time_2 = str2num(zef.MUSIC.inv_time_2.Value);';
zef.MUSIC.number_of_frames.ValueChangedFcn = 'zef.number_of_frames = str2num(zef.MUSIC.number_of_frames.Value);';
zef.MUSIC.inv_time_3.ValueChangedFcn = 'zef.inv_time_3 = str2num(zef.MUSIC.inv_time_3.Value);';
zef.MUSIC.inv_data_segment.ValueChangedFcn = 'zef.inv_data_segment = str2num(zef.MUSIC.inv_data_segment.Value);';
zef.MUSIC.normalize_data.ValueChangedFcn = 'zef.normalize_data = str2num(zef.MUSIC.normalize_data.Value);';
zef.MUSIC.StartButton.ButtonPushedFcn = 'zef.reconstruction = MUSIC_iteration;';
zef.MUSIC.CloseButton.ButtonPushedFcn = 'delete(zef.MUSIC);';

%set fonts
set(findobj(zef.MUSIC.UIFigure.Children,'-property','FontSize'),'FontSize',zef.font_size);
zef_ui_adopt_app(zef.MUSIC.UIFigure, 'ZEFFIRO Interface: MUSIC');
