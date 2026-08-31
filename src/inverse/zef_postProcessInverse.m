function [z] = zef_postProcessInverse(z_inverse, procFile)
%ZEF_POSTPROCESSINVERSE  Map inverter output back to full source grid (legacy indexing).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Expands each frame of z_inverse from the reduced lead-field column layout
%   (procFile.s_ind_1 or s_ind_2) to length procFile.sizeL2 (or 3*sizeL2 for
%   normal-constrained mode 3). For mode 2, collapses the three Cartesian
%   components at constrained nodes (s_ind_4) to a scalar times fixed
%   source_directions. For mode 3, multiplies by per-node direction cosines and
%   stores the 3-component vector in s_ind_2 slots.
%
%   z = zef_postProcessInverse(z_inverse, procFile)
%
%   Inputs
%     z_inverse - cell array, one n_columns x 1 vector per frame from inverter.
%     procFile  - struct from zef_processLeadfields (source_direction_mode,
%                 source_directions, s_ind_*, sizeL2, n_interp).
%
%   Output
%     z         - cell array of full-grid reconstruction vectors per frame.
%
%   See also zef_postProcessInverseClassObj, zef_processLeadfields,
%            zef_process_inversion.

source_direction_mode=procFile.source_direction_mode;
source_directions=procFile.source_directions;
s_ind_1=procFile.s_ind_1;
s_ind_2=procFile.s_ind_2;
s_ind_4=procFile.s_ind_4;
sizeL2=procFile.sizeL2;
n_interp=procFile.n_interp;

z=cell(size(z_inverse));
for f_ind=1:length(z_inverse)
z_vec=z_inverse{f_ind};

    if ismember(source_direction_mode, [1,2])
        z_aux = zeros(sizeL2,1);
    end
    if source_direction_mode == 3
        z_aux = zeros(3*sizeL2,1);
    end

    if ismember(source_direction_mode,[2])
        z_vec_aux = (z_vec(s_ind_4) + z_vec(n_interp+s_ind_4) + z_vec(2*n_interp+s_ind_4))/3;
        z_vec(s_ind_4) = z_vec_aux.*source_directions(s_ind_4,1);
        z_vec(n_interp+s_ind_4) = z_vec_aux.*source_directions(s_ind_4,2);
        z_vec(2*n_interp+s_ind_4) = z_vec_aux.*source_directions(s_ind_4,3);
    end

    if ismember(source_direction_mode,[3])
        z_vec = [z_vec.*source_directions(:,1); z_vec.*source_directions(:,2); z_vec.*source_directions(:,3)];
    end

    if ismember(source_direction_mode,[1 2])
        z_aux(s_ind_1) = z_vec;
    end
    if ismember(source_direction_mode,[3])
        z_aux(s_ind_2) = z_vec;
    end

    z{f_ind} = z_aux;

end
