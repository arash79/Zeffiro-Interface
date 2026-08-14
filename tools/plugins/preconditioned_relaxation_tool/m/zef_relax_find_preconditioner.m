function [relax_preconditioner, relax_preconditioner_permutation] = zef_relax_find_preconditioner
%ZEF_RELAX_FIND_PRECONDITIONER  Build relaxation preconditioner (does not invert).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from Find preconditioner. Reads relax_multires_* and
%   relax_preconditioner_type from base zef. Writes the two outputs that
%   zef_relax_iteration expects. Does not write zef.reconstruction.
%

relax_multires_sparsity = evalin('base','zef.relax_multires_sparsity');
relax_multires_n_decompositions = evalin('base','zef.relax_multires_n_decompositions');
relax_multires_n_levels = evalin('base','zef.relax_multires_n_levels');
relax_preconditioner_type = evalin('base','zef.relax_preconditioner_type');

% Dropdown (zef_relax.mlapp): 1 Block diagonal RAMUS, 2 Diagonal RAMUS,
% 3 Identity. Types 1–2 loop relax_multires_n_decompositions coarsenings
% of source_positions; type 3 skips RAMUS and stores speye(3*n_interp).
if relax_preconditioner_type == 1
    relax_preconditioner = cell(0);
    relax_preconditioner_permutation = cell(0);
    h = zef_waitbar(0,1,'RAMUS preconditioner');

    [~,n_interp, procFile] = zef_processLeadfields(evalin('base','zef.source_direction_mode'));
    center_points = evalin('base','zef.source_positions');
    center_points = center_points(procFile.s_ind_0,:);

    for zef_i = 1 : relax_multires_n_decompositions
        zef_waitbar(zef_i,relax_multires_n_decompositions,h,'RAMUS preconditioner');
        [relax_multigrid_dec, relax_multigrid_ind, relax_multigrid_perm] = zef_make_multigrid_dec(center_points,relax_multires_sparsity,1,relax_multires_n_levels);
        [relax_preconditioner{zef_i}, relax_preconditioner_permutation{zef_i}] = zef_block_diagonal_preconditioner_uniform_prior(evalin('base','zef.L'), relax_multigrid_dec, relax_multigrid_perm);
    end
    close(h)

elseif relax_preconditioner_type == 2
    relax_preconditioner = cell(0);
    relax_preconditioner_permutation = cell(0);
    h = zef_waitbar(0,1,'RAMUS preconditioner');

    [~,n_interp, procFile] = zef_processLeadfields(evalin('base','zef.source_direction_mode'));
    center_points = evalin('base','zef.source_positions');
    center_points = center_points(procFile.s_ind_0,:);

    for zef_i = 1 : relax_multires_n_decompositions
        zef_waitbar(zef_i,relax_multires_n_decompositions,h,'RAMUS preconditioner');
        [relax_multigrid_dec, relax_multigrid_ind, relax_multigrid_perm] = zef_make_multigrid_dec(center_points,relax_multires_sparsity,1,relax_multires_n_levels);
        [relax_preconditioner{zef_i}, relax_preconditioner_permutation{zef_i}] = zef_diagonal_preconditioner_uniform_prior(evalin('base','zef.L'), relax_multigrid_dec, relax_multigrid_perm);
    end
    close(h)

elseif relax_preconditioner_type == 3
    relax_preconditioner = cell(0);
    relax_preconditioner_permutation = cell(0);
    h = zef_waitbar(0,1,'RAMUS preconditioner');

    [~,n_interp] = zef_processLeadfields(evalin('base','zef.source_direction_mode'));

    relax_preconditioner{1} = speye(3*n_interp);
    relax_preconditioner_permutation{1}{1} = [1:3*n_interp]';
    relax_preconditioner_permutation{1}{2} = [1:3*n_interp]';
    close(h);

end
