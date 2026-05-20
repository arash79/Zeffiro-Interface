% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.RAPMUSIC (read)
%   zef.RAPMUSIC_leadfield_lambda (read, write)
%   zef.RAPMUSIC_n_dipoles (read, write)
%   zef.font_size (read)
%   zef.inv_high_cut_frequency (read, write)
%   zef.inv_hyperprior (read, write)
%   zef.inv_low_cut_frequency (read, write)
%   zef.inv_sampling_frequency (read, write)
%   zef.inv_snr (read, write)
%   zef.inv_time_1 (read, write)
%   zef.inv_time_2 (read, write)
%   zef.inv_time_3 (read, write)
%   zef.normalize_data (read, write)
%   zef.number_of_frames (read, write)
%   zef.reconstruction (read, write)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.RAPMUSIC = RAPMUSIC_app;

%_ Initial values _
zef.RAPMUSIC.RAPMUSIC_leadfield_lambda.Value = '1e-3';
zef.RAPMUSIC.inv_snr.Value = '30';
zef.RAPMUSIC.RAPMUSIC_n_dipoles.Value = '8';
zef.RAPMUSIC.inv_sampling_frequency.Value = num2str(zef.inv_sampling_frequency);
zef.RAPMUSIC.inv_low_cut_frequency.Value =  num2str(zef.inv_low_cut_frequency);
zef.RAPMUSIC.inv_high_cut_frequency.Value =  num2str(zef.inv_high_cut_frequency);
zef.RAPMUSIC.inv_time_1.Value =  num2str(zef.inv_time_1);
zef.RAPMUSIC.inv_time_2.Value = num2str(zef.inv_time_2);
zef.RAPMUSIC.number_of_frames.Value = num2str(zef.number_of_frames);
zef.RAPMUSIC.inv_time_3.Value = num2str(zef.inv_time_3);

if ~isfield(zef,'RAPMUSIC_leadfield_lambda')
    zef.RAPMUSIC_leadfield_lambda = 1e-3;
end
if ~isfield(zef,'RAPMUSIC_n_dipoles')
    zef.RAPMUSIC_n_dipoles = 8;
end

%set parameters if saved in ZI:
%(Naming concept: zef.RAPMUSIC."field" = zef."field")
zef_props = properties(zef.RAPMUSIC);
for zef_i = 1:length(zef_props)
    if isfield(zef,zef_props{zef_i})
        zef.RAPMUSIC.(zef_props{zef_i}).Value = num2str(zef.(zef_props{zef_i}));
    end
end
clear zef_props zef_i

%_ Functions _
zef.RAPMUSIC.inv_hyperprior.ValueChangedFcn = 'zef.inv_hyperprior = str2num(zef.RAPMUSIC.inv_hyperprior.Value);';
zef.RAPMUSIC.RAPMUSIC_leadfield_lambda.ValueChangedFcn = 'zef.RAPMUSIC_leadfield_lambda = str2num(zef.RAPMUSIC.RAPMUSIC_leadfield_lambda.Value);';
zef.RAPMUSIC.inv_snr.ValueChangedFcn = 'zef.inv_snr = str2num(zef.RAPMUSIC.inv_snr.Value);';
zef.RAPMUSIC.RAPMUSIC_n_dipoles.ValueChangedFcn = 'zef.RAPMUSIC_n_dipoles = str2num(zef.RAPMUSIC.RAPMUSIC_n_dipoles.Value);';
zef.RAPMUSIC.inv_sampling_frequency.ValueChangedFcn = 'zef.inv_sampling_frequency = str2num(zef.RAPMUSIC.inv_sampling_frequency.Value);';
zef.RAPMUSIC.inv_low_cut_frequency.ValueChangedFcn = 'zef.inv_low_cut_frequency = str2num(zef.RAPMUSIC.inv_low_cut_frequency.Value);';
zef.RAPMUSIC.inv_high_cut_frequency.ValueChangedFcn = 'zef.inv_high_cut_frequency = str2num(zef.RAPMUSIC.inv_high_cut_frequency.Value);';
zef.RAPMUSIC.inv_time_1.ValueChangedFcn = 'zef.inv_time_1 = str2num(zef.RAPMUSIC.inv_time_1.Value);';
zef.RAPMUSIC.inv_time_2.ValueChangedFcn = 'zef.inv_time_2 = str2num(zef.RAPMUSIC.inv_time_2.Value);';
zef.RAPMUSIC.number_of_frames.ValueChangedFcn = 'zef.number_of_frames = str2num(zef.RAPMUSIC.number_of_frames.Value);';
zef.RAPMUSIC.inv_time_3.ValueChangedFcn = 'zef.inv_time_3 = str2num(zef.RAPMUSIC.inv_time_3.Value);';
zef.RAPMUSIC.normalize_data.ValueChangedFcn = 'zef.normalize_data = str2num(zef.RAPMUSIC.normalize_data.Value);';
zef.RAPMUSIC.StartButton.ButtonPushedFcn = 'zef.reconstruction = RAP_MUSIC_iteration;';
zef.RAPMUSIC.CloseButton.ButtonPushedFcn = 'delete(zef.RAPMUSIC);';

%set fonts
set(findobj(zef.RAPMUSIC.UIFigure.Children,'-property','FontSize'),'FontSize',zef.font_size);
