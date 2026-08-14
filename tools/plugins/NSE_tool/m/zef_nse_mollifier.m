function [f, df] = zef_nse_mollifier(r,t,t_min,t_max)
%ZEF_NSE_MOLLIFIER  C∞ bump that ramps 0→1→0 on [t_min, t_max] with relative width r.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by zef_nse_balloon_model_solver when relative_mollification > 0.
%   I1: rising edge, I2: plateau f=1, I3: falling edge. Standard exp(1-1/(1-x^2)) bump.
%
%   [f, df] = zef_nse_mollifier(r, t)
%   [f, df] = zef_nse_mollifier(r, t, t_min, t_max)
%
%   See also zef_nse_balloon_model_solver.
%

if nargin < 3
t_min = t(1);
t_max = t(end);
end

% Rising / plateau / falling partitions of [t_min, t_max].
I1 = find(t < t_min + 0.5*r*(t_max - t_min));
I2 = find(t < t_max - 0.5*r*(t_max - t_min));
I3 = find(t >= t_max - 0.5*r*(t_max - t_min));

I3 = setdiff(I3,I2);
I2 = setdiff(I2,I1);

f = zeros(size(t));
f(I1) = exp(1-1./(1-((t(I1)-0.5*r*(t_max - t_min)-t_min).^2./(0.5*r*(t_max - t_min)).^2)));
f(I3) = exp(1-1./(1-((t(I3)+0.5*r*(t_max - t_min)-t_max).^2./(0.5*r*(t_max - t_min)).^2)));
f(I2) = 1;

df = zeros(size(t));
df(I1) = -2.*f(I1).*(t(I1)-0.5*r*(t_max - t_min)-t_min)./(0.5*r*(t_max - t_min)).^2./(1-(t(I1)-0.5*r*(t_max - t_min)-t_min).^2./(0.5*r*(t_max - t_min)).^2).^2;
df(I3) = -2.*f(I3).*(t(I3)+0.5*r*(t_max - t_min)-t_max)./(0.5*r*(t_max - t_min)).^2./(1-(t(I3)+0.5*r*(t_max - t_min)-t_max).^2./(0.5*r*(t_max - t_min)).^2).^2;
df(I2) = 0;
df(isnan(df)) = 0;

end
