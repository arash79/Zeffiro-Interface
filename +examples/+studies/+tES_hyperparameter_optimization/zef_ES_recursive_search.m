function zef = zef_ES_recursive_search(zef, num_lattice)
% --- Zeffiro documentation header ---
% examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search — Example or study script demonstrating zef_ES_recursive_search.
%
% Purpose:
%   Example or study script demonstrating zef_ES_recursive_search.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Inputs:
%   zef
%   num_lattice
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.ES_step_size (read, write)
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
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    zef.ES_step_size = num_lattice;
    zef_ES_find_currents;
    adapted_y_ES{1} = zef.y_ES_interval;
    original_window = zef.ES_step_size;
    adapt_instances = zef.ES_step_size;  % M = number of adaptive refinement steps
    adapt_window = 40;                   % K = size of adaptive search window
    [alpha, epsilon] = zef_ES_find_parameters(zef, original_window);

    % Shrinkage factors for narrowing alpha and epsilon ranges.
    s_alpha  = (min(alpha)/max(alpha))^((adapt_window-1)/(adapt_window*adapt_instances));
    s_epsilon = (min(epsilon)/max(epsilon))^((adapt_window-1)/(adapt_window*adapt_instances));

    % Recursive refinement: recenter grid around best (sr, sc) each iteration.
    for adapt_instances_ind = 2 : adapt_instances
    [sr, sc] = zef_ES_objective_function(zef);

    [alpha_psi, epsilon_psi] = examples.studies.tES_hyperparameter_optimization.helpers.zef_ES_centralize_recursive_search( ...
        alpha, epsilon, sr, sc, original_window, s_alpha, s_epsilon, 0);

    zef_ES_find_currents(zef, alpha_psi, epsilon_psi, original_window)
    adapted_y_ES{adapt_instances_ind} = zef.y_ES_interval;

    alpha = alpha_psi;
    epsilon = epsilon_psi;
end

zef.adapted_y_ES = adapted_y_ES;
end
