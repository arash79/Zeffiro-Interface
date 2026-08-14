function [decomposition_ind, decomposition_count, dof_positions] = zef_decompose_soure_space(source_count, center_points)
%ZEF_DECOMPOSE_SOURE_SPACE  Bin source positions onto a 3-D lattice (typo: soure).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [ind, count, dof_positions] = zef_decompose_soure_space(source_count, center_points)
%
%   Lattice spacing so that n_cells ≈ source_count inside the bounding box
%   of center_points (N-by-3). ind(i) is the linear lattice index of
%   source i; count is occupancy per unique index; dof_positions are
%   meshgrid centres. Filename spelling is soure.
%
%   See also zef_average_lead_field.

min_x = min(center_points(:,1));
max_x = max(center_points(:,1));
min_y = min(center_points(:,2));
max_y = max(center_points(:,2));
min_z = min(center_points(:,3));
max_z = max(center_points(:,3));

lattice_constant = source_count.^(1/3)/((max_x - min_x)*(max_y - min_y)*(max_z - min_z))^(1/3);
lattice_res_x = floor(lattice_constant*(max_x - min_x));
lattice_res_y = floor(lattice_constant*(max_y - min_y));
lattice_res_z = floor(lattice_constant*(max_z - min_z));

l_d_x = (max_x - min_x)/(lattice_res_x + 1);
l_d_y = (max_y - min_y)/(lattice_res_y + 1);
l_d_z = (max_z - min_z)/(lattice_res_z + 1);

min_x = min_x + l_d_x;
max_x = max_x - l_d_x;
min_y = min_y + l_d_y;
max_y = max_y - l_d_y;
min_z = min_z + l_d_z;
max_z = max_z - l_d_z;

[X_lattice, Y_lattice, Z_lattice] = meshgrid(linspace(min_x,max_x,lattice_res_x),linspace(min_y,max_y,lattice_res_y),linspace(min_z,max_z,lattice_res_z));

lattice_ind_aux = [max(1,ceil(lattice_res_x*(center_points(:,1)-min(center_points(:,1)))./(max(center_points(:,1))-min(center_points(:,1))))) ...
    max(1,ceil(lattice_res_y*(center_points(:,2)-min(center_points(:,2)))./(max(center_points(:,2))-min(center_points(:,2)))))...
    max(1,ceil(lattice_res_z*(center_points(:,3)-min(center_points(:,3)))./(max(center_points(:,3))-min(center_points(:,3)))))];

lattice_ind_aux = (lattice_ind_aux(:,3)-1)*lattice_res_x*lattice_res_y + (lattice_ind_aux(:,1)-1)*lattice_res_y + lattice_ind_aux(:,2);

dof_positions = [X_lattice(:) Y_lattice(:) Z_lattice(:)];
decomposition_ind = lattice_ind_aux;
[aux_vec, i_a, i_c] = unique(decomposition_ind);
decomposition_count = accumarray(i_c,1);

end
