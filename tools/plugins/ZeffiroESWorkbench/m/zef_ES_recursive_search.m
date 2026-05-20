function zef = zef_ES_recursive_search(zef, num_lattice, recursive_instances, varargin)
% --- Zeffiro documentation header ---
% zef_ES_recursive_search — Zef ES recursive search.
%
% Purpose:
%   Zef ES recursive search.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   num_lattice
%   recursive_instances
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.ES_step_size (read)
%   zef.adapted_y_ES (read, write)
%   zef.y_ES_interval (read)
%
% Calls (project):
%   zef_ES_centralize_recursive_search
%   zef_ES_find_currents
%   zef_ES_find_parameters
%   zef_ES_objective_function
%   zef_ES_recursive_search
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ES_recursive_search(zef, num_lattice, recursive_instances, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef             = zef_ES_find_currents(zef);
adapted_y_ES{1} = zef.y_ES_interval;

% num_lattice     = num_lattice;
% num_lattice    = num_lattice;         % K = Size of the adaptive window
% recursive_instances = recursive_instances; % M = Number of adaptive instances

% original_window = zef.ES_step_size;
% recursive_instances = zef.ES_step_size; % M = Number of adaptive instances
% recursive_window    = 40;               % K = Size of the adaptive window

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
