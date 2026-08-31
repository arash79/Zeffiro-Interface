function zef_plot_strips(strip_struct)
%ZEF_PLOT_STRIPS  Queue renderer: grey surfaces for every StripTool probe.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   trisurf of strip_struct.faces{i}/vertices{i} for i = 1:probe_num.
%   Default strip_struct is caller zef.strip_struct. Axes are caller
%   zef.h_axes1 (not h_axes_image). Tag: 'additional: electrode strip'.
%   No electrode spheres (those are zef_plot_strip).
%
%   zef_plot_strips
%   zef_plot_strips(strip_struct)
%
%   See also zef_plot_strip.

hold on
if nargin == 0;
    strip_struct = evalin('caller','zef.strip_struct');
end
haxes = evalin('caller','zef.h_axes1');
axes(haxes);
hold on
for i=1:strip_struct.probe_num
    
    tri1 = strip_struct.faces{i};
    
    x1 = strip_struct.vertices{i}(:,1);
    y1 = strip_struct.vertices{i}(:,2);
    z1 = strip_struct.vertices{i}(:,3);
    
    
    h_t1 = trisurf(tri1,x1,y1,z1);
    h_t1.EdgeColor = 'none';
    h_t1.Tag = 'additional: electrode strip';
    h_t1.FaceColor = [0.6 0.6 0.6];

end

hold off

end
