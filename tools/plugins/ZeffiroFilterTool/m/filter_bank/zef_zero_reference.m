function [processed_data] = zef_zero_reference(f)
%ZEF_ZERO_REFERENCE  Pipeline stage: subtract the mean across channels at each sample.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: empty. Output: zero-mean reference.
%
%Description: Set the reference (average) level to zero
%Input:
%Output: Data with zero reference (average) level
%

mean_f = mean(f);
processed_data = f - mean_f(ones(size(f,1),1),:);
