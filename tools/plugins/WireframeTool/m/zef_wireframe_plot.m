function zef_wireframe_plot(w_t,w_n)
%ZEF_WIREFRAME_PLOT  Phong-lit gray surface for a wireframe patch.
%
%   Copyright © 2019- Sampsa Pursiainen, Liisa-Ida Sorsa, Christelle Eyraud, Jean-Michel Geffrin.
%   GPU-ToRRe-3D wireframe modeling package.
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_wireframe_plot(w_t, w_n)
%
%   Arguments w_t / w_n are unused. Sets FaceColor, two lights, axis
%   equal, Tag 'surface' on h_t and hides h_a — both must already exist
%   in the caller workspace. Called from the wireframe creator. No zef
%   I/O.
%
%   See also wireframe.

h_t.FaceColor  = 0.5*[1 1 1];
h_l = light;
h_l.Position = [1 0 0];
h_l = light;
h_l.Position = [-1 0 0];
lighting phong;
axis equal;
h_t.Tag = 'surface';

h_a.Visible = 'off';

end
