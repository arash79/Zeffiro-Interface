function [L, source_positions,source_directions] = zef_lead_field_filter(L,source_positions,source_directions,filter_quantile,varargin)




%ZEF_LEAD_FIELD_FILTER  Drop lead-field columns whose column-norm exceeds a quantile.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from every EEG/MEG/EIT/TES wrapper after zef_lead_field_matrix.
%   amp = sqrt(sum(L.^2)) per column. Columns with amp > quantile(amp,
%   filter_quantile) are removed, together with the matching source rows.
%   filter_quantile=1 (examples.forward.lead_field_example default) removes
%   nothing. If size(L,2)==3*n_positions, a source is dropped as a triplet.
%
%   [L, source_positions, source_directions] = zef_lead_field_filter( ...
%       L, source_positions, source_directions, filter_quantile)
%
%   Input
%     L                  - [n_sensors × n_cols]
%     source_positions   - [n × 3]
%     source_directions  - [n × 3] or []
%     filter_quantile    - scalar in [0,1], typically zef.lead_field_filter_quantile
%
%   See also zef_eeg_lead_field_isotropic, zef_lead_field_matrix.

amp_vec = sqrt(sum(L.^2));
filter_ind = find(amp_vec > quantile(amp_vec,filter_quantile));
source_ind = [1:size(source_positions,1)]';

if isequal(size(L,2),3*size(source_positions,1))
    source_filter_ind = repmat(source_ind',3,1);
    source_filter_ind = source_filter_ind(:);
    source_filter_ind = unique(source_filter_ind(filter_ind));
    source_ind = setdiff(source_ind,source_filter_ind);
    source_ind = source_ind(:);
    lead_field_ind = [3*(source_ind-1)+1 3*(source_ind-1)+2 3*source_ind]';
    lead_field_ind = lead_field_ind(:);
    source_positions = source_positions(source_ind,:);
    L = L(:,lead_field_ind);
else
    source_filter_ind = unique(source_ind(filter_ind));
    source_ind = setdiff(source_ind,source_filter_ind);
    source_ind = source_ind(:);
    source_positions = source_positions(source_ind,:);
    L = L(:,source_ind);
end

if not(isempty(source_directions))
    source_directions = source_directions(source_ind,:);
end

end
