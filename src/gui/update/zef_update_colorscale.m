function  colorscale_val = zef_update_colorscale(varargin)
%ZEF_UPDATE_COLORSCALE  Figure-tool Linear/Logarithmic popup (no String= label).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the popup Tag='colorscaleselection' on the Figure tool
%   (string={'Linear','Logarithmic'}, next to **Colormap:**) and sets
%   axes1 ColorScale to 'linear' (Value 1) or 'log' (Value 2). This is
%   MATLAB's axes ColorScale, not zef.inv_scale: reconstruction log/sqrt
%   scaling is applied in zef_plot_volume as 20*log10 or sqrt of the
%   field before CData is written.
%
%   The Figure-tool Callback writes the returned Value to
%   zef.update_colorscale when gca is parented to h_zeffiro.
%
%   colorscale_val = zef_update_colorscale
%   colorscale_val = zef_update_colorscale(h_figure)
%
%   See also zef_update_colorscale_min, zef_plot_volume, zef_figure_tool.
if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

if not(isempty(varargin))
    h_figure = varargin{1};
else
    h_figure = eval('zef.h_zeffiro');
end

h = zef_ui_axes(h_figure);
h_object = zef_ui_control(h_figure, 'colorscaleselection');

colorscale_val = h_object.Value;

if isequal(colorscale_val,1)
    h.ColorScale = 'linear';
elseif isequal(colorscale_val,2)
    h.ColorScale = 'log';
end

end
