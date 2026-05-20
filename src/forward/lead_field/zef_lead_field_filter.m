function [L, source_positions,source_directions] = zef_lead_field_filter(L,source_positions,source_directions,filter_quantile,varargin)
% --- Zeffiro documentation header ---
% zef_lead_field_filter — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Inputs:
%   L
%   source_positions
%   source_directions
%   filter_quantile
%   varargin
%
% Outputs:
%   L
%   source_positions
%   source_directions
%
% Calls (project):
%   zef_lead_field_filter
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[L, source_positions, source_directions]] = zef_lead_field_filter(L, source_positions, source_directions, filter_quantile, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header



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
