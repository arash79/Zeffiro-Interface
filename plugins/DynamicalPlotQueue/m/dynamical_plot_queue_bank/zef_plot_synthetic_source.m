function zef_plot_synthetic_source(varargin)
%ZEF_PLOT_SYNTHETIC_SOURCE  Queue renderer: quiver3 markers at inv_synth_source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Bank List item. Reads zef.inv_synth_source from base (Find synthetic
%   source: xyz, orientation, amplitude, noise, visual size, color index).
%   Draws on caller h_axes_image. Color cycle k r g b y m c via column 10.
%   Marker size and line width scale with 6*sqrt(column 9). Tag:
%   'additional: synthetic source'. varargin unused.
%
%   zef_plot_synthetic_source
%
%   See also zef_plot_3D_arrow_synthetic_source, zef_plot_dpq.

color_cell = {'k','r','g','b','y','m','c'};
h_axes = evalin('caller','h_axes_image');
s = evalin('base','zef.inv_synth_source');
s_o = s(:,4:6)./repmat(sqrt(sum(s(:,4:6).^2,2)),1,3);
for i = 1 : size(s,1)
    source_size = 6*sqrt(s(i,9));
    h_source = quiver3(h_axes,s(i,1),s(i,2),s(i,3),s(i,9)*s_o(i,1),s(i,9)*s_o(i,2),s(i,9)*s_o(i,3),'Marker','o','MarkerSize',0.8*source_size);
    set(h_source,'Tag','additional: synthetic source');
    set(h_source,'linewidth',0.5*source_size);
    set(h_source,'color',color_cell{s(i,10)})

end

end
