function zef = zef_axes_popup(zef)
%ZEF_AXES_POPUP  Copy Figure-tool axes1 (and colorbar) into a standalone figure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Uses gcf as the source. Creates a figure named
%   'ZEFFIRO Interface: Figure tool axes popup' (Tag
%   figure_tool_axes_popup) to the right of zef.h_zeffiro, copyobj of
%   children with Tag 'axes1' or Type 'colorbar', then reparents them
%   and sets axes OuterPosition to [0.2 0.2 0.6 0.6]. nargout==0
%   assignin base zef.
%
%   Callers: Figure-tool context menu **Axes pop-up**; Mesh visualization
%   tool button **Axes pop-up**.
%
%   zef = zef_axes_popup(zef)
%   zef_axes_popup  % reads and writes base zef
%
%   See also zef_figure_tool, zef_mesh_visualization_tool.
if nargin == 0
    zef = evalin('base','zef');
end

zef.h_figure_aux = gcf;
src_pos = [100 100 640 480];
try
    zef.h_zeffiro.Units = 'pixels';
    src_pos = zef.h_zeffiro.Position;
catch
end
pop_w = 640;
pop_h = 480;
zef.h_zeffiro_axes_popup = figure(...
    'PaperUnits',get(0,'defaultfigurePaperUnits'),...
    'Units','pixels',...
    'Position',[src_pos(1)+src_pos(3)+12, src_pos(2), pop_w, pop_h],...
    'Renderer',get(0,'defaultfigureRenderer'),...
    'Visible',zef.use_display,...
    'Color',zef_ui_theme().color.bg,...
    'CloseRequestFcn','closereq;',...
    'CurrentAxesMode','manual',...
    'IntegerHandle','off',...
    'NextPlot',get(0,'defaultfigureNextPlot'),...
    'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
    'DoubleBuffer','off',...
    'MenuBar','figure',...
    'ToolBar','figure',...
    'Name','ZEFFIRO Interface: Figure tool axes popup',...
    'NumberTitle','off',...
    'HandleVisibility','on',...
    'Tag','figure_tool_axes_popup',...
    'UserData',[],...
    'WindowStyle','normal',......
    'Resize',get(0,'defaultfigureResize'),...
    'PaperPosition',get(0,'defaultfigurePaperPosition'),...
    'PaperSize',[20.99999864 29.69999902],...
    'PaperType',get(0,'defaultfigurePaperType'),...
    'InvertHardcopy',true,...
    'ScreenPixelsPerInchMode','manual' );

try
    addToolbarExplorationButtons(zef.h_zeffiro_axes_popup);
catch
end
zef.h_object_aux_new = copyobj(zef_ui_axes(zef.h_figure_aux), zef.h_figure_aux);
h_cb = findall(zef.h_figure_aux, 'Type', 'colorbar');
if ~isempty(h_cb)
    zef.h_object_aux_new = [zef.h_object_aux_new; copyobj(h_cb, zef.h_figure_aux)];
end
for zef_i = 1 : length(zef.h_object_aux_new)
    if isequal(zef.h_object_aux_new(zef_i).Tag,'axes1')
        zef.h_object_aux_new(zef_i).Parent = zef.h_zeffiro_axes_popup;
        zef.h_object_aux_new(zef_i).Units = 'normalized';
        zef.h_object_aux_new(zef_i).OuterPosition = [0.02 0.02 0.96 0.96];
        try
            th = zef_ui_theme();
            zef.h_zeffiro_axes_popup.Color = th.color.axesBg;
            zef.h_object_aux_new(zef_i).Color = th.color.axesBg;
        catch
        end
        try
            axis(zef.h_object_aux_new(zef_i), 'image');
        catch
        end
        try
            enableDefaultInteractivity(zef.h_object_aux_new(zef_i));
        catch
        end
        try
            zef.h_object_aux_new(zef_i).Toolbar.Visible = 'on';
        catch
        end
    end
end
for zef_i = 1 : length(zef.h_object_aux_new)
    if isequal(zef.h_object_aux_new(zef_i).Type,'colorbar')
        zef.h_object_aux_new(zef_i).Parent = zef.h_zeffiro_axes_popup;
    end
end

zef = rmfield(zef,{'h_figure_aux','h_object_aux_new'});

clear zef_i

if nargout == 0
    assignin('base','zef',zef);
end

try
    zef_window_manager('standalone', zef.h_zeffiro_axes_popup);
catch
end
try
    zef_ui_apply_size(zef.h_zeffiro_axes_popup, 640, 480, 400, 320);
catch
end
try
    zef_ui_ready(zef.h_zeffiro_axes_popup);
catch
    try
        zef_ui_apply_theme(zef.h_zeffiro_axes_popup);
    catch
    end
end
try
    th = zef_ui_theme();
    zef.h_zeffiro_axes_popup.Color = th.color.axesBg;
    ax = findall(zef.h_zeffiro_axes_popup, 'Type', 'axes', 'Tag', 'axes1');
    if ~isempty(ax)
        ax(1).Color = th.color.axesBg;
    end
catch
end
try
    zef_window_manager('raise', zef.h_zeffiro_axes_popup);
catch
end

end
