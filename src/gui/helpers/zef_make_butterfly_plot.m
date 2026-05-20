%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef_make_butterfly_plot(zef,h_axes_image)
% --- Zeffiro documentation header ---
% zef_make_butterfly_plot — Zef make butterfly plot.
%
% Purpose:
%   Zef make butterfly plot.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   h_axes_image
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.bf_data_segment (read)
%   zef.bf_high_cut_frequency (read)
%   zef.bf_low_cut_frequency (read)
%   zef.bf_normalize_data (read)
%   zef.bf_sampling_frequency (read)
%   zef.bf_time_1 (read)
%   zef.bf_time_2 (read)
%   zef.colormap_size (read)
%   zef.font_size (read)
%   zef.h_axes1 (read)
%   zef.inv_data_segment (read, write)
%   zef.inv_high_cut_frequency (read, write)
%   zef.inv_low_cut_frequency (read, write)
%   zef.inv_normalize_data (read, write)
%   zef.inv_sampling_frequency (read, write)
%   … (3 more)
%
% Calls (project):
%   zef_getFilteredData
%   zef_getTimeStep
%   zef_make_butterfly_plot
%   zef_set_timepointline
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_make_butterfly_plot(zef, h_axes_image)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
