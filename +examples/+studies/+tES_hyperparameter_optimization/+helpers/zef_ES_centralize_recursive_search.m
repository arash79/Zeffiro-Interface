function [alpha_psi, epsilon_psi] = zef_ES_centralize_recursive_search(alpha, epsilon, sr, sc, original_window, s_alpha, s_epsilon, varargin)
% --- Zeffiro documentation header ---
% examples.studies.tES_hyperparameter_optimization.helpers.zef_ES_centralize_recursive_search — Example or study script demonstrating zef_ES_centralize_recursive_search.
%
% Purpose:
%   Example or study script demonstrating zef_ES_centralize_recursive_search.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Inputs:
%   alpha
%   epsilon
%   sr
%   sc
%   original_window
%   s_alpha
%   s_epsilon
%   varargin
%
% Outputs:
%   alpha_psi
%   epsilon_psi
%
% Calls (project):
%   zef_ES_centralize_recursive_search
%   zef_ES_find_parameters
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[alpha_psi, epsilon_psi]] = examples.studies.tES_hyperparameter_optimization.helpers.zef_ES_centralize_recursive_search(alpha, epsilon, sr, sc, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    if nargin >= 8 && ~isempty(varargin) && ismember(varargin{1}, [0 1])
        non_floating_flag = varargin{1};
    else
        non_floating_flag = 1;
    end

    B_alpha   = sqrt((max(alpha)/min(alpha))*s_alpha);
    B_epsilon = sqrt((max(epsilon)/min(epsilon))*s_epsilon);

    if non_floating_flag
        psi_alpha_lower_lim = max(min(alpha), (1/B_alpha)*alpha(sc));
        psi_alpha_upper_lim = min(max(alpha), B_alpha*alpha(sc));
    else
        psi_alpha_lower_lim = (1/B_alpha)*alpha(sc);
        psi_alpha_upper_lim = B_alpha*alpha(sc);
    end

    if non_floating_flag
        psi_epsilon_lower_lim = max(min(epsilon), (1/B_epsilon)*epsilon(sr));
        psi_epsilon_upper_lim = min(max(epsilon), B_epsilon*epsilon(sr));
    else
        psi_epsilon_lower_lim = (1/B_epsilon)*epsilon(sr);
        psi_epsilon_upper_lim = B_epsilon*epsilon(sr);
    end

    [alpha_psi, epsilon_psi] = zef_ES_find_parameters(...
        psi_alpha_lower_lim, ...
        psi_alpha_upper_lim, ...
        psi_epsilon_upper_lim, ...
        psi_epsilon_lower_lim, ...
        original_window);
end
