function zef_toggle_figure_controls
%ZEF_TOGGLE_FIGURE_CONTROLS  Show or hide Figure-tool sliders and widen the axes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure tool button **Toggle controls** (h_toggle_controls;
%   Callback "zef_toggle_figure_controls;"). Function with no arguments;
%   uses gcf / CurrentAxes (also evalin base for the same handles).
%
%   Toggles Visible on children whose Tag contains slidertext, slider, or
%   toggleedgesbutton. Flips togglecontrolsbutton UserData between 1 and
%   2 (empty → treat as 1, then store 2). Scales that button's normalized
%   x-position by 83/68 or 68/83, and axes1 plus rightColorbar x-position
%   by 8769/6000 or the reciprocal, matching the slider strip width.
%
%   See also zef_toggle_edges, zef_figure_tool.

toggle_mode = 'unlocked';
current_figure = gcf;
tgb = findobj(get(gcf,'Children'),'Tag','togglecontrolsbutton');
toggle_status = tgb.UserData;
if isempty(toggle_status)
    toggle_status = 1;
    tgb.UserData = 2;
elseif isequal(toggle_status,1)
    tgb.UserData = 2;
elseif isequal(toggle_status,2)
    tgb.UserData = 1;
end

h_figure = evalin('base','gcf');
h_axes = evalin('base','get(gcf, ''CurrentAxes'');');
h = get(h_figure,'children');

for i = 1 : length(h)

    if contains(get(h(i),'Tag'),{'slidertext','slider','toggleedgesbutton'})
        if get(h(i),'Visible')
            set(h(i),'Visible','off')
        else
            set(h(i),'Visible','on')
        end
    end

    if isequal(get(h(i),'Tag'),'togglecontrolsbutton')
        h_togglecontrolsbutton = h(i);
        set(h(i),'units','normalized');
        togglecontrolsbuttonposition = get(h(i),'position');
        if toggle_status == 1
            toggle_scale = 83/68;
            set(h(i),'Position',[toggle_scale*h(i).Position(1) h(i).Position(2:4) ])
        else
            toggle_scale = 68/83;
            set(h(i),'Position',[toggle_scale*h(i).Position(1) h(i).Position(2:4)])
        end
        set(h(i),'units','pixels');
    end
end

set(h_axes,'units','normalized');
h_colorbar = findobj(h,'Tag','rightColorbar');
set(h_colorbar,'units','normalized');
if toggle_status == 1
    toggle_scale = 8769/6000;
    set(h_axes,'Position',[toggle_scale*h_axes.Position(1) h_axes.Position(2:4) ]);
    h_colorbar = findobj(h,'Tag','rightColorbar');
    if not(isempty(h_colorbar))
        set(h_colorbar,'Position',[toggle_scale*h_colorbar.Position(1) h_colorbar.Position(2:4) ]);
    end
else
    toggle_scale = 6000/8769;
    set(h_axes,'Position',[toggle_scale*h_axes.Position(1) h_axes.Position(2:4) ])
    h_colorbar = findobj(h,'Tag','rightColorbar');
    if not(isempty(h_colorbar))
        set(h_colorbar,'Position',[toggle_scale*h_colorbar.Position(1) h_colorbar.Position(2:4) ]);
    end
end

set(h_axes,'units','pixels');

end
