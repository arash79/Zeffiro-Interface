function d = zef_mcmc_posterior_mean_divisor(n_iter_process, n_burn_in, n_chains)
%ZEF_MCMC_POSTERIOR_MEAN_DIVISOR  Number of post-burn-in Gibbs samples.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Outer loop i = 1:n_iter_process adds n_chains samples when i > n_burn_in.
%   The mean divisor is therefore (n_iter_process − n_burn_in) * n_chains,
%   not n_iter_process * n_chains − n_burn_in (those agree only for one
%   chain or zero burn-in).
%
%   d = zef_mcmc_posterior_mean_divisor(n_iter_process, n_burn_in, n_chains)
%
%   See also zef_mcmc.

arguments
    n_iter_process (1, 1) double {mustBeInteger, mustBePositive}
    n_burn_in (1, 1) double {mustBeInteger, mustBeNonnegative}
    n_chains (1, 1) double {mustBeInteger, mustBePositive}
end

n_kept = n_iter_process - n_burn_in;
if n_kept < 1
    error("Zeffiro:MCMC:EmptyPosterior", ...
        "n_burn_in (%d) leaves no samples in %d outer iterations.", ...
        n_burn_in, n_iter_process);
end
d = n_kept * n_chains;

end
