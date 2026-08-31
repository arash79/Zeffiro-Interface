function [alpha_psi, epsilon_psi] = zef_ES_centralize_recursive_search(alpha, epsilon, sr, sc, original_window, s_alpha, s_epsilon, varargin)
%ZEF_ES_CENTRALIZE_RECURSIVE_SEARCH  Shift α and ε lattices so the current (sr,sc) optimum is centered.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_ES_recursive_search. Builds a new log-spaced lattice
%   around alpha(sc) and epsilon(sr) with geometric half-width B, then
%   zef_ES_find_parameters(..., original_window).
%   varargin{1}==1 (or omitted via ismember) clamps the window to the
%   original α/ε range.
%
%   [alpha_psi, epsilon_psi] = zef_ES_centralize_recursive_search(alpha, ...
%       epsilon, sr, sc, original_window, s_alpha, s_epsilon, flag)
%
%   See also zef_ES_find_parameters, zef_ES_recursive_search.
%

if ismember(varargin{1}, 1)
   non_floating_flag = varargin{1};
else
   non_floating_flag = 1;
end

B_alpha   = sqrt(( max(alpha)/min(alpha) )*s_alpha);
B_epsilon = sqrt(( max(epsilon)/min(epsilon) )*s_epsilon);

if non_floating_flag
    psi_alpha_lower_lim = max(min(alpha),  (1/B_alpha)*alpha(sc));
    psi_alpha_upper_lim = min(max(alpha),  (  B_alpha)*alpha(sc));
else
    psi_alpha_lower_lim = ((1/B_alpha)*alpha(sc));
    psi_alpha_upper_lim = (   B_alpha)*alpha(sc);
end

if non_floating_flag
    psi_epsilon_lower_lim = max(min(epsilon), (1/B_epsilon)*epsilon(sr));
    psi_epsilon_upper_lim = min(max(epsilon), (  B_epsilon)*epsilon(sr));
else
    psi_epsilon_lower_lim = ((1/B_epsilon)*epsilon(sr));
    psi_epsilon_upper_lim = (   B_epsilon)*epsilon(sr);
end

[alpha_psi, epsilon_psi] = zef_ES_find_parameters(...
    psi_alpha_lower_lim, ...
    psi_alpha_upper_lim, ...
    psi_epsilon_upper_lim, ...
    psi_epsilon_lower_lim, ...
    original_window);
end
