function zef = zef_ES_recursive_search(zef, num_lattice, recursive_instances, varargin)
%ZEF_ES_RECURSIVE_SEARCH  Repeated zef_ES_find_currents on a shrinking α/ε window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by zef_ES_find_currents_recursive (not a button). First full-grid
%   find_currents, then recursive_instances-1 refinements: pick (sr,sc)
%   with zef_ES_objective_function, recentre α/ε with
%   zef_ES_centralize_recursive_search, solve again. Stores
%   zef.adapted_y_ES{k} = y_ES_interval after each instance.
%
%   zef = zef_ES_recursive_search(zef, num_lattice, recursive_instances)
%
%   See also zef_ES_centralize_recursive_search, zef_ES_find_currents.
%

zef             = zef_ES_find_currents(zef);
adapted_y_ES{1} = zef.y_ES_interval;

[alpha, epsilon] = zef_ES_find_parameters(zef, num_lattice);

s_alpha  =  (min(alpha)/max(alpha))    ^((num_lattice-1)/(num_lattice*recursive_instances));
s_epsilon=  (min(epsilon)/max(epsilon))^((num_lattice-1)/(num_lattice*recursive_instances));

for recursive_instances_ind = 2:recursive_instances
    [sr, sc] = zef_ES_objective_function(zef);
    
    [alpha_psi, epsilon_psi] = zef_ES_centralize_recursive_search(alpha, epsilon, sr, sc, num_lattice, s_alpha, s_epsilon, 0);
    alpha_psi   = fliplr(alpha_psi);
    epsilon_psi = fliplr(epsilon_psi);
    
    zef = zef_ES_find_currents(zef, alpha_psi, epsilon_psi);
    adapted_y_ES{recursive_instances_ind} = zef.y_ES_interval;
    
    alpha = alpha_psi;
    epsilon = epsilon_psi;
end

zef.adapted_y_ES = adapted_y_ES;

if nargout == 0
assignin('caller','zef',zef);
end
end
