function [tetra_ind_out, face_ind_out] = zef_find_adjacent_tetra(tetra,tetra_ind,face_ind)
% --- Zeffiro documentation header ---
% zef_find_adjacent_tetra — Zef find adjacent tetra.
%
% Purpose:
%   Zef find adjacent tetra.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   tetra
%   tetra_ind
%   face_ind
%
% Outputs:
%   tetra_ind_out
%   face_ind_out
%
% Calls (project):
%   zef_find_adjacent_tetra
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[tetra_ind_out, face_ind_out]] = zef_find_adjacent_tetra(tetra, tetra_ind, face_ind)` with project root and `src` on the path.
% --- End Zeffiro documentation header


tetra_ind = tetra_ind(:);
face_ind = face_ind(:);

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

tetra_ind_out = tetra_ind;
face_ind_out = face_ind;

triangles = zeros(length(tetra_ind),3);

for i = 1 : 3
    I = sub2ind(size(tetra),tetra_ind,ind_m(face_ind,i));
    triangles(:,i) = tetra(I);
end

t_aux_2 = sort(triangles,2);

for i = 1 : 4

    t_aux_1 = sort(tetra(:,ind_m(i,:)),2);

    ind_aux_1 = find(ismember(t_aux_1,t_aux_2,'rows'));

    diff_ind = find(ismember([ind_aux_1(:) i*ones(length(ind_aux_1),1)],[tetra_ind face_ind],'rows'));
    diff_ind = setdiff([1:length(ind_aux_1)]',diff_ind);
    ind_aux_1 = ind_aux_1(diff_ind);

    ind_aux_2 = find(ismember(t_aux_2,t_aux_1(ind_aux_1,:),'rows'));

    t_aux_1 = tetra(ind_aux_1,ind_m(i,:));
    t_aux_3 = triangles(ind_aux_2,:);

    [~,t_s_1] = sortrows(t_aux_1);
    [~,t_s_2] = sortrows(t_aux_3);

    tetra_ind_out(ind_aux_2(t_s_2)) = ind_aux_1(t_s_1);
    face_ind_out(ind_aux_2) = i;

end

end
