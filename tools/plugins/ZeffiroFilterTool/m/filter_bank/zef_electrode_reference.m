function [processed_data] = zef_electrode_reference(f,electrode_index)
%ZEF_ELECTRODE_REFERENCE  Pipeline stage: subtract one electrode row from all channels.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: Electrode index [Default: 1].
%
%Description: Set a given electrode as a reference
%Input: 1 Electrode index [Default: 1],
%Output: Data with zero reference level set by the electrode with the given index.
%

ref_f = f(electrode_index,:);
processed_data = f - ref_f(ones(size(f,1),1),:);
