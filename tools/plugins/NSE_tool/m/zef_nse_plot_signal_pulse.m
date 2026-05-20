
function  zef_nse_plot_signal_pulse(zef, nse_field)
% --- Zeffiro documentation header ---
% zef_nse_plot_signal_pulse — Zef nse plot signal pulse.
%
% Purpose:
%   Zef nse plot signal pulse.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   nse_field
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_axes1 (read)
%
% Calls (project):
%   zef_nse_plot_signal_pulse
%   zef_nse_signal_pulse
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_nse_plot_signal_pulse(zef, nse_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header


h_axes = zef.h_axes1;
axes(h_axes);
c_map = lines(1);
c_map = c_map + 0.1; 
c_map = c_map/max(c_map(:));

mmhg_conversion = 101325/760;

plot_data_time =  [0:nse_field.time_step_length:nse_field.cycle_length];
plot_vec = zef_nse_signal_pulse(plot_data_time,nse_field)/mmhg_conversion;

    h_plot = plot(h_axes,plot_data_time, plot_vec);
    h_plot.Color = c_map(1,:);
    h_plot.LineWidth = 2;

%h_axes.FontSize = 18;
h_axes.XGrid = 'on';
h_axes.YGrid = 'on';
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
set(h_axes,'xlim',[plot_data_time(1) plot_data_time(end)])
set(h_axes,'ylim',[min(plot_vec(:)) 1.05*max(plot_vec(:))])
set(h_axes,'FontSize',zef.font_size);
pbaspect([2 1 1]);

end
