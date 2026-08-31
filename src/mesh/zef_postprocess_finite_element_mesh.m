%ZEF_POSTPROCESS_FINITE_ELEMENT_MESH  Mesh-tool "Postprocess FEM mesh" wrapper.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Bound to h_pushbutton34. Calls zef_postprocess_fem_mesh then
%   zef_update_fig_details. The Create FEM mesh button already postprocesses
%   once; this button re-runs smoothing/relabeling on the existing volume.
%
%   Side effects: updates zef.nodes, zef.tetra, zef.sigma (via postprocess).
%
%   See also zef_postprocess_fem_mesh, zef_create_finite_element_mesh.

[zef]=zef_postprocess_fem_mesh(zef);zef=zef_update_fig_details(zef);
