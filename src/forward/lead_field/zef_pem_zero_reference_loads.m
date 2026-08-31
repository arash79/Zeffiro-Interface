function b = zef_pem_zero_reference_loads(b, block_ind, electrode_model, impedance_inf)
%ZEF_PEM_ZERO_REFERENCE_LOADS  Zero PEM infinite-Z reference column in a PCG block.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Infinite-impedance PEM uses electrode 1 as a Dirichlet reference, so that
%   load column is identically zero. CPU PCG walks electrodes in blocks of
%   parallel_processes * processes_per_core; only the column whose global
%   index is 1 must be zeroed, not the entire first block.
%
%   b = zef_pem_zero_reference_loads(b, block_ind, electrode_model, impedance_inf)
%
%   Inputs
%     b               - N×n_block right-hand side (one column per electrode
%                       in this block). A single electrode may be N×1.
%     block_ind       - 1×n_block global electrode indices, or a scalar.
%     electrode_model - 'PEM' or other (no-op unless PEM).
%     impedance_inf   - 1 → apply the reference; 0 → no-op.
%
%   See also zef_transfer_matrix.

if ~(ischar(electrode_model) || isstring(electrode_model))
    return
end
if ~(strcmp(char(electrode_model), 'PEM') && impedance_inf == 1)
    return
end

ref_col = find(block_ind(:) == 1, 1);
if ~isempty(ref_col)
    b(:, ref_col) = 0;
end

end
