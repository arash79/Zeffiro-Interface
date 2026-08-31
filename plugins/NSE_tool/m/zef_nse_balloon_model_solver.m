function [y, dy] = zef_nse_balloon_model_solver(time_vec, blood_flow_signal_decay_rate, flow_dependent_elimination_constant, neural_activity_impulse, relative_mollification,t_min, t_max)
%ZEF_NSE_BALLOON_MODEL_SOLVER  Closed-form balloon / NVC ODE (two real roots) with optional mollifier.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Helper for solver_type 3 (zef_nse_haemodynamic_response_solver), not a
%   button. y'' + a y' + b y = g with roots r1,r2 of r^2 + a r + b = 0.
%   Optional relative_mollification > 0 multiplies y by zef_nse_mollifier.
%
%   [y, dy] = zef_nse_balloon_model_solver(t, a, b, g)
%   [y, dy] = zef_nse_balloon_model_solver(t, a, b, g, r, t_min, t_max)
%
%   See also zef_nse_mollifier, zef_nse_haemodynamic_response_solver.
%

if nargin < 5
relative_mollification = 0;
end

if nargin < 6
t_min = time_vec(1);
t_max = time_vec(end);
end

f = 1; 
df = 0; 

if relative_mollification > 0
[f, df] = zef_nse_mollifier(relative_mollification,time_vec,t_min,t_max);
end

a = blood_flow_signal_decay_rate;
b = flow_dependent_elimination_constant;
g = neural_activity_impulse;
t = time_vec;

% Characteristic roots of y'' + a y' + b y = g (assumes a^2 > 4b).
r1 = (-a + sqrt(a^2 - 4*b)) / 2;
r2 = (-a - sqrt(a^2 - 4*b)) / 2;

C1 = g / ( r1 - r2 );
C2 = -g / ( r1 - r2 );

y = C1 * exp(r1 * t) + C2 * exp(r2 * t);
dy = C1 * r1 * exp(r1 * t) + C2 * r2 * exp(r2 * t);

y = y.*f;
dy = y.*df + dy.*f;

end
