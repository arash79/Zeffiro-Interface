function zef = hb_sampler(zef)
%HB_SAMPLER  Inverse tools → Hierarchical Bayesian Sampler.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = hb_sampler(zef)
%
%   INI callback in every default/asteroid profile. Opens zef_mcmc_window
%   via zef_tool_start(..., 'zef_open_mcmc', 1/4, 0) — not
%   fig/hb_sampler.fig. Start runs zef_mcmc(zef) into reconstruction
%   and reconstruction_information. Needs zef.L and zef.measurements.
%   No inverse.*Inverter. nargin 0 / nargout 0 use base zef.
%
%   See also zef_open_mcmc, zef_mcmc.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_open_mcmc',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
