function [eit_ind,eit_count] = make_eit_dec(nodes,tetrahedra,brain_ind,source_ind)



%ZEF_MAKE_EIT_DEC  Nearest-source binning of brain tetrahedra for EIT DOFs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Centroids of all tetrahedra vs centroids of source_ind. knnsearch maps
%   each brain_ind tetra onto a source tetra. eit_count is occupancy per
%   source bin. Called from EIT FEM when rebuilding the decomposition.
%   Public name is zef_make_eit_dec (filename); the function line is
%   historical make_eit_dec.
%
%   [eit_ind, eit_count] = zef_make_eit_dec(nodes, tetrahedra, brain_ind, source_ind)
%
%   Input: nodes [n × 3], tetrahedra [n_tet × 4], brain_ind and source_ind
%   integer tetra indices. Output eit_ind [numel(brain_ind) × 1], eit_count
%   [n_unique_sources × 1].
%
%   See also zef_lead_field_eit_fem, zef_make_gravity_dec.

h = zef_waitbar(0,1,'Field decomposition');

center_points = (nodes(tetrahedra(:,1),:) + nodes(tetrahedra(:,2),:) + nodes(tetrahedra(:,3),:)+ nodes(tetrahedra(:,4),:))/4;
center_points = center_points';
source_points = center_points(:,source_ind);
center_points = center_points(:,brain_ind);

MdlKDT = KDTreeSearcher(source_points');
source_interpolation_aux = knnsearch(MdlKDT,center_points');

eit_ind = source_interpolation_aux;
[aux_vec, i_a, i_c] = unique(source_interpolation_aux);
eit_count = accumarray(i_c,1);

zef_waitbar(1,1,h,'Field decomposition');

close(h);

end
