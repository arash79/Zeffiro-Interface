function [X, Y, Z, pml_ind] = zef_pml_mesh(inner_radius,outer_radius,lattice_size,max_size)
%ZEF_PML_MESH  Graded Cartesian lattice for a perfectly matched outer layer.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   When a compartment has <tag>_sources == -1, zef_create_fem_mesh calls
%   this instead of a uniform meshgrid. Nodes with Chebyshev radius
%   (max(|x|,|y|,|z|)) larger than inner_radius are pushed outward along
%   the same ray with geometrically growing spacing, then the whole grid
%   is scaled so the farthest coordinate equals outer_radius.
%
%   [X, Y, Z, pml_ind] = zef_pml_mesh(inner_radius, outer_radius, lattice_size, max_size)
%
%   Inputs (all scalars, same length unit as the head surfaces)
%     inner_radius  - Chebyshev radius of the non-PML bounding box
%                     (max abs coordinate of non-PML reuna_p).
%     outer_radius  - desired outer Chebyshev radius of the PML box.
%                     create_fem_mesh may already have multiplied by
%                     inner_radius when pml_outer_radius_unit == 1.
%     lattice_size  - inner-cube edge (zef.mesh_resolution).
%     max_size      - target outermost cell size. create_fem_mesh may
%                     already have multiplied by mesh_resolution when
%                     pml_max_size_unit == 1.
%
%   Outputs
%     X, Y, Z  - ndgrid-style arrays from meshgrid, same size, centred at 0.
%                Interior (|coord| ≤ inner_radius) stays uniform.
%     pml_ind  - linear indices of nodes with any |coord| > inner_radius
%                (the ones that were stretched).
%
%   Algorithm
%     Iterate growth_param until lattice_size * growth_param^extra_layers
%     matches max_size. extra_layers is the number of geometric shells
%     that fit between inner_radius and outer_radius. Nodes outside the
%     inner cube are remapped with the geometric-series radius
%     inner + lattice_size * g * (1-g^N)/(1-g).
%
%   See also zef_create_fem_mesh, zef_process_meshes.

growth_param = 1 + 1e-15;

convergence_value = Inf;

% Solve for the geometric growth so the last shell width is max_size.
while convergence_value > 1e-5

    extra_layers = round(log(((outer_radius-inner_radius)*(growth_param - 1))/(lattice_size*growth_param) + 1)/log(growth_param));

    growth_param_new = exp(log(max_size/lattice_size)/extra_layers);

    convergence_value = abs(max_size - lattice_size*growth_param^extra_layers)/max_size;

    growth_param = growth_param_new;

end

extra_layers = round(log(((outer_radius-inner_radius)*(growth_param - 1))/(lattice_size*growth_param) + 1)/log(growth_param));

intermediate_radius = extra_layers*lattice_size + inner_radius;

% Uniform meshgrid covering a cube of half-width intermediate_radius.
[X,Y,Z] = meshgrid([-intermediate_radius:2*intermediate_radius/(round(2*intermediate_radius/lattice_size)):intermediate_radius]);

I_X = find(abs(X) > inner_radius);
I_Y = find(abs(Y) > inner_radius);
I_Z = find(abs(Z) > inner_radius);
pml_ind = unique([I_X(:); I_Y(:) ; I_Z(:)]);

% Layer index N = how many inner-cell steps this node sits outside the cube.
R_aux = max(abs([X(pml_ind) Y(pml_ind) Z(pml_ind)]),[],2);
N = round((R_aux - inner_radius)/lattice_size);

X_inner = inner_radius.*X(pml_ind)./R_aux;
Y_inner = inner_radius.*Y(pml_ind)./R_aux;
Z_inner = inner_radius.*Z(pml_ind)./R_aux;

R_new = inner_radius + lattice_size.*growth_param*(1-growth_param.^N)./(1-growth_param);
R_old = inner_radius + N*lattice_size;

X(pml_ind) = R_new.*X(pml_ind)./R_old;
Y(pml_ind) = R_new.*Y(pml_ind)./R_old;
Z(pml_ind) = R_new.*Z(pml_ind)./R_old;

% Scale the whole grid so max(|X|,|Y|,|Z|) equals outer_radius.
s = max(abs([X(:) ; Y(:); Z(:)]));
X = outer_radius*X/s;
Y = outer_radius*Y/s;
Z = outer_radius*Z/s;

end
