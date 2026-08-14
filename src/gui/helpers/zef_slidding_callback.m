function []=zef_slidding_callback
%ZEF_SLIDDING_CALLBACK  Figure-tool **Time:** slider (legacy spelling).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired as Callback of zef.h_slider in zef_figure_tool. If
%   zef.store_cdata is true, plays one stored frame via
%   zef_play_cdata(1, slider Value). Otherwise maps the slider (0–1)
%   onto the frame range
%     ceil(((frame_stop-frame_start+frame_step)/frame_step)*Value)
%   and writes both zef.frame_start and zef.frame_stop to that index,
%   then redraws: visualization_type 2 → zef_visualize_volume, 3 →
%   zef_visualize_surfaces.
%
%   See also zef_figure_tool, zef_play_cdata.


if evalin('base','zef.store_cdata')
    zef_play_cdata(1,get(gcbo,'Value'));
else
    l_r = evalin('base','(zef.frame_stop-zef.frame_start+zef.frame_step)/zef.frame_step;');
    evalin('base',['zef.frame_start=' ,num2str(ceil(l_r*evalin('base','zef.h_slider.Value'))),';']);
    evalin('base',['zef.frame_stop=' ,num2str(ceil(l_r*evalin('base','zef.h_slider.Value'))),';']);
    if isequal(evalin('base','zef.visualization_type'),2)
        evalin('base','zef_visualize_volume');
    elseif isequal(evalin('base','zef.visualization_type'),3)
        evalin('base','zef_visualize_surfaces');
    end

end

end
