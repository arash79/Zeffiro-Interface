function srsc = zef_ES_centralize_recursive_search_window(adapt_window, original_window, param_aux, s_opt)
% --- Zeffiro documentation header ---
% zef_ES_centralize_recursive_search_window — Zef ES centralize recursive search window.
%
% Purpose:
%   Zef ES centralize recursive search window.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   adapt_window
%   original_window
%   param_aux
%   s_opt
%
% Outputs:
%   srsc
%
% Calls (project):
%   zef_ES_centralize_recursive_search_window
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[srsc] = zef_ES_centralize_recursive_search_window(adapt_window, original_window, param_aux, s_opt)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if adapt_window < length(param_aux)
    if any(s_opt + (-floor(adapt_window/2):floor(adapt_window/2)) >= length(param_aux)) %&& ~any(s_opt + (-floor(adapt_window/2):floor(adapt_window/2)) >= original_window)
        nnz_aux = nnz(s_opt + (-floor(adapt_window/2):floor(adapt_window/2)) > length(param_aux));
        srsc = s_opt - nnz_aux + (-floor(adapt_window/2):floor(adapt_window/2));
    else
        if floor(adapt_window/2) < s_opt && ~any(s_opt + (-floor(adapt_window/2):floor(adapt_window/2)) >= original_window)
            srsc = s_opt + (-floor(adapt_window/2):floor(adapt_window/2));
        else
            srsc = (-floor(adapt_window/2):floor(adapt_window/2)) - min((-floor(adapt_window/2):floor(adapt_window/2))-1);
        end
    end
else
    srsc = 1:adapt_window;
end
end
