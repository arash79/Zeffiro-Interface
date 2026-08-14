function [current_score] = zef_ES_score_sys(y, rwnnz)
%ZEF_ES_SCORE_SYS  Count how many sorted |y| entries reach fraction rwnnz of ||y||_1.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not a wrapper on zef_ES_rwnnz and not bound in zef_ES_optimization_window.
%   Converts a table y to an array if needed, then find(cumsum(sort(|y|))/||y||_1 >= rwnnz, 1).
%   Does not zero entries. No zef fields.
%
%   k = zef_ES_score_sys(y, rwnnz)
%
%   See also zef_ES_rwnnz.
%

if istable(y)
    y = table2array(y);
end
sorted_y = cumsum(sort(abs(y),'descend'));
y = sorted_y/norm(y,1);
current_score = find(y >= rwnnz,1);
end
