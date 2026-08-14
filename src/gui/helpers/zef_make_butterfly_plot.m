function zef_make_butterfly_plot(zef,h_axes_image)
%ZEF_MAKE_BUTTERFLY_PLOT  Overlay filtered measurement traces vs time.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Copies zef.bf_* (sampling frequency, band edges, data segment,
%   time window, normalize) onto the inv_* fields zef_getFilteredData
%   / zef_getTimeStep read, then plot(t', f') on h_axes_image. Default
%   axes: caller's h_axes_image if that variable exists, else
%   zef.h_axes1 (Figure tool). Each line and the axes have ButtonDownFcn
%   zef_set_timepointline. Title is Time value = inv_time_1. Deletes any
%   Legend sibling of the axes.
%
%   Called from the butterfly-plot window **Plot** button
%   (zef_butterfly_plot_app: zef_update_butterfly_plot then this).
%   Menu: Forward tools → Butterfly plot → zef_butterfly_plot →
%   zef_butterfly_plot_start.
%
%   zef_make_butterfly_plot(zef)
%   zef_make_butterfly_plot(zef, h_axes_image)
%
%   Inputs
%     zef           - session with bf_* filter fields and measurements.
%     h_axes_image  - target axes; optional (see default above).
%
%   See also zef_butterfly_plot, zef_getFilteredData, zef_set_timepointline.
if nargin < 2
    if evalin('caller','exist(''h_axes_image'',''var'')')
        h_axes_image = evalin('caller','h_axes_image');
    else
        h_axes_image = zef.h_axes1;
    end
end

zef.inv_sampling_frequency = zef.bf_sampling_frequency;
zef.inv_low_cut_frequency = zef.bf_low_cut_frequency;
zef.inv_high_cut_frequency = zef.bf_high_cut_frequency;
zef.inv_data_segment = zef.bf_data_segment;
zef.inv_time_1 = zef.bf_time_1;
zef.inv_time_2 = zef.bf_time_2;
zef.inv_normalize_data = zef.bf_normalize_data;

f = zef_getFilteredData(zef);
zef.inv_time_interval_averaging = 0;
[f,t] = zef_getTimeStep(f,1,zef);

h_axes_image.Title.String = ['Time value = ' num2str(zef.inv_time_1)];
h_axes_image.Colormap = lines(zef.colormap_size);
h_plot = plot(t',f');

for i = 1 : length(h_plot)
    h_plot(i).ButtonDownFcn = 'zef_set_timepointline(get(gcbo,''Parent''));';
end
h_axes_image.ButtonDownFcn = 'zef_set_timepointline(gcbo);';
set(h_plot,'linewidth',0.5);
set(h_axes_image,'xlim',[t(1) t(end)]);
f_range = max(f(:))-min(f(:));
set(gca,'ylim',[min(f(:))-0.05*f_range max(f(:))+0.05*f_range]);
set(h_axes_image,'ygrid','on');
set(h_axes_image,'xgrid','on');
set(h_axes_image,'fontsize',zef.font_size);
set(h_axes_image,'linewidth',0.5);
set(h_axes_image,'box','on');
h_legend = findobj(h_axes_image.Parent.Children,'Type','Legend');
delete(h_legend)

end
