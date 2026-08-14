function srsc = zef_ES_centralize_recursive_search_window(adapt_window, original_window, param_aux, s_opt)
%ZEF_ES_CENTRALIZE_RECURSIVE_SEARCH_WINDOW  Clamp a sliding index window to [1, length(param)].
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Index arithmetic only — not a GUI window despite the name. Not called
%   from zef_ES_optimization_window or from zef_ES_centralize_recursive_search
%   (that function uses zef_ES_find_parameters instead).
%
%   srsc = zef_ES_centralize_recursive_search_window(adapt_window, ...
%       original_window, param_aux, s_opt)
%
%   See also zef_ES_centralize_recursive_search.
%

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
