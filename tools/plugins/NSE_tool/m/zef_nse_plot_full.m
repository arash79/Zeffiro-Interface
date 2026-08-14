
function  zef_nse_plot_full(zef, nse_field, plot_vec, y_label, legend_text)
%ZEF_NSE_PLOT_FULL  Time series of plot_vec on h_axes1 from start_time to time_length.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_nse_plot_graph for non-epoched graph_types. Time axis
%   is linspace(start_time, time_length, n_time); not the solver dt.
%   Optional legend_text for multi-column plot_vec.
%
%   zef_nse_plot_full(zef, nse_field, plot_vec, y_label)
%   zef_nse_plot_full(zef, nse_field, plot_vec, y_label, legend_text)
%
%   See also zef_nse_plot_epoched, zef_nse_plot_graph.
%

h_axes = zef.h_axes1;
axes(h_axes);
c_map = lines(size(plot_vec,2));
c_map = c_map + 0.1; 
c_map = c_map/max(c_map(:));

n_time = length(plot_vec);
time_step_length_aux = (nse_field.time_length - nse_field.start_time)/(n_time-1);
plot_data_time = [nse_field.start_time:time_step_length_aux:nse_field.time_length];

for i = 1:size(plot_vec,2)

    h_plot = plot(h_axes,plot_data_time, plot_vec(:,i));
    h_plot.Color = c_map(i,:);
    h_plot.LineWidth = 2;
    
    if i == 1
        hold on
    end

end
if nargin >= 5
legend(legend_text,'Location','northwest');
else
    delete(h_axes.Legend);
end

hold off;

%h_axes.FontSize = 18;
h_axes.XGrid = 'on';
h_axes.YGrid = 'on';
xlabel('Time (s)');
ylabel(y_label);
set(h_axes,'xlim',[plot_data_time(1) plot_data_time(end)])
set(h_axes,'ylim',[min(plot_vec(:)) max(plot_vec(:))])
set(h_axes,'FontSize',zef.font_size);
pbaspect([2 1 1]);

end
