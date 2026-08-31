%ZEF_FILTER_SCHROLL_BAR  Time-axis slider under h_axes1 using zef.filter_zoom.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. First step of the Plot button. Deletes an existing
%   h_scroll_bar if present, then uicontrol slider on zef.h_zeffiro
%   just below h_axes1. Callback sets h_axes1 XLim from
%   (1-filter_zoom)*N/fs * slider + [0 filter_zoom*N/fs] using
%   processed_data width and filter_sampling_rate. Filename is
%   schroll (not scroll).
%
%   See also zef_filter_plot_data.
if isfield(zef,'h_scroll_bar')
    delete(zef.h_scroll_bar);
end
zef.h_scroll_bar=uicontrol(zef.h_zeffiro,'style','slider','units',zef.h_axes1.Units,'position',[zef.h_axes1.Position(1:3) 0.05*zef.h_axes1.Position(4)]);
zef.h_scroll_bar.Position(2) = zef.h_axes1.Position(2)-0.1*zef.h_axes1.Position(4);
set(zef.h_scroll_bar,'callback','set(zef.h_axes1,''xlim'',(1-zef.filter_zoom)*double(size(zef.processed_data,2))./zef.filter_sampling_rate*get(gcbo,''value'') + [0 zef.filter_zoom*double(size(zef.processed_data,2))./zef.filter_sampling_rate]);');
