function d = zef_nse_threshold_distribution(d,quantile_min,quantile_max)
%ZEF_NSE_THRESHOLD_DISTRIBUTION  Clamp |d| into [quantile_min, quantile_max].
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by zef_nse_reconstruction before visualization. Values below the
%   lower abs-quantile are raised to that floor; values above the upper
%   quantile are clipped.
%
%   d = zef_nse_threshold_distribution(d, quantile_min, quantile_max)
%
%   See also zef_nse_reconstruction.

a = quantile(abs(d),quantile_min);
b = quantile(abs(d),quantile_max);
d(find(abs(d)<a))=a;
d(find(abs(d)>b))=b;

end
