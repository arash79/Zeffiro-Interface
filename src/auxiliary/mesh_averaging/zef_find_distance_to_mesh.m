%ZEF_FIND_DISTANCE_TO_MESH  Lab script: hist of grey-matter node distances.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace zef (tetra, sigma(:,2), nodes, reuna_t/p) and
%   compartment_ind. Samples ~10000 unique surface nodes of label 15,
%   zef_distance_to_mesh to the union of reuna compartments
%   compartment_ind-1 and compartment_ind. Figures 1 (hist 0–3) and 2
%   (cdf). One-off mesh-quality helper.
%
%   See also zef_get_surface_triangles, zef_distance_to_mesh.

number_of_points = 10000;
grey_matter_ind = 15;

surface_triangles = zef_get_surface_triangles(zef.tetra,zef.sigma(:,2),grey_matter_ind);
nodes_ind_aux = unique(surface_triangles);
nodes_ind_aux = nodes_ind_aux([1:floor(length(nodes_ind_aux)/(number_of_points-1)):length(nodes_ind_aux)],:);

distance_vec = zeros(length(nodes_ind_aux),1);

surface_triangles_w = zef.reuna_t{compartment_ind-1};
surface_nodes_w = zef.reuna_p{compartment_ind-1};

surface_triangles_g = zef.reuna_t{compartment_ind};
surface_nodes_g = zef.reuna_p{compartment_ind};

surface_triangles_wg = [surface_triangles_w; surface_triangles_g+size(surface_nodes_w,1)];
surface_nodes_wg = [surface_nodes_w; surface_nodes_g];

d  =  zef_distance_to_mesh(zef.nodes(nodes_ind_aux,:), surface_nodes_wg, surface_triangles_wg);

figure(1)
; [a, b] = hist(d,1000); set(gca,'xlim',[0 3]);
figure(2); c = cumsum(a); plot(b,c./max(c)); set(gca,'xlim',[0 3],'xgrid','on','ygrid','on')
