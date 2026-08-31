function [interp_ind, L_projected] = zef_project_L_in_roi(s_roi,s_o,L,n_interp,procFile)
%ZEF_PROJECT_L_IN_ROI  Restrict L columns in an ROI to orientation s_o (cortical normal).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [interp_ind, L_projected] = zef_project_L_in_roi(s_roi, s_o, L, n_interp, procFile)
%
%   Called from zef_find_source_patch in normal-orientation mode after
%   zef_processLeadfields. Maps ROI indices through procFile.s_ind_0.
%   Does not write zef.
%
%   See also zef_find_source_patch.

L_1 = L(:,1:n_interp);
L_2 = L(:,n_interp+1:2*n_interp);
L_3 = L(:,2*n_interp+1:3*n_interp);

%convert roi indices to interpolated indices
interp_ind = zeros(length(s_roi),1);
for j=1:length(s_roi)
    interp_ind(j) = find(procFile.s_ind_0(:)==s_roi(j));
end

%get non restricted sources
not_projected = setdiff(interp_ind,procFile.s_ind_4);

% orientation of non restricted sources is the given oriention
s_1 = s_o(:,1)';
s_2 = s_o(:,2)';
s_3 = s_o(:,3)';

%project leadfield of those sources 
ones_vec = ones(size(L,1),1);
ones_vec_2 = ones(size(L_1(:,not_projected),2),1);
L_0 = L_1(:,not_projected).*s_1(ones_vec,ones_vec_2) + L_2(:,not_projected).*s_2(ones_vec,ones_vec_2) + L_3(:,not_projected).*s_3(ones_vec,ones_vec_2); 
L_projected = L;
L_projected(:,not_projected) = L_0;
L_projected(:,n_interp+not_projected) = L_0;
L_projected(:,2*n_interp+not_projected) = L_0;

end
