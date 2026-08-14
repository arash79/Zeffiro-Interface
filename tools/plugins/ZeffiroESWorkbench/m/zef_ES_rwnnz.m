function [current_score_nnz, y] = zef_ES_rwnnz(y, rwnnz, varargin)
%ZEF_ES_RWNNZ  Zero small |y| entries until relative weighted nnz reaches 1-rwnnz.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sparsity post-process on electrode currents (optimize_current and
%   y_ES_interval.nnz). Sort |y| descending; keep the smallest k such that
%   cumsum(|y|)/sum(|y|) >= 1-rwnnz, then zero the rest. Optional third
%   argument is a hard cap on k (ES_score_dose). Cap == 2 keeps only the
%   most positive and most negative entries.
%
%   [k, y] = zef_ES_rwnnz(y, rwnnz)
%   [k, y] = zef_ES_rwnnz(y, rwnnz, score_dose)
%
%   See also zef_ES_optimize_current.
%

if any(isnan(y)) || isempty(y)
    y = [];
    current_score_nnz = 0;
    return
end

rwnnz = 1 - rwnnz;

current_score_nnz_lim = Inf;

if not(isempty(varargin))
    current_score_nnz_lim = varargin{1};
end

if not(isequal(current_score_nnz_lim, 2))
    
    sorted_y = sort(abs(y),'descend');
    sorted_sum_y = sum(sorted_y);
    if sorted_sum_y == 0
        current_score_ind = 1:length(y);
        current_score_nnz = 0;
    else
        % Keep the leading mass of |y| until the cumulative fraction hits rwnnz.
        sorted_y_normalized = cumsum(sorted_y)/(sorted_sum_y);
        current_score_nnz = find(sorted_y_normalized >= rwnnz,1);
        current_score_nnz = min(current_score_nnz, current_score_nnz_lim);
        if not(isempty(current_score_nnz))
            current_score_ind = find(abs(y) < sorted_y(current_score_nnz));
        else
            current_score_ind = [];
        end
    end
    
    if not(isempty(current_score_ind))
        y(current_score_ind) = 0;
    end
    
else
    
    [~, y_positive] = max(y(:));
    [~, y_negative] = min(y(:));
    
    current_score_nnz = 2;
    
    y(setdiff(1:length(y), [y_negative y_positive])) = 0;
end
end
