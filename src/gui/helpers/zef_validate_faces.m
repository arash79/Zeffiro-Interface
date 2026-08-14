function [faces, faces_count] = zef_validate_faces(tetra)
%ZEF_VALIDATE_FACES  Unique sorted faces of a tet mesh, with occurrence counts.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds the four faces of every tet (vertex triples sorted, plus a
%   local face id 1–4 and the tet row), then unique(...,'rows') on the
%   triples. faces_count is accumarray of how often each unique triple
%   appears (1 = boundary face, 2 = interior). Does not repair geometry.
%
%   No first-party callers in this tree.
%
%   [faces, faces_count] = zef_validate_faces(tetra)
%
%   Inputs
%     tetra - T-by-4 1-based vertex indices.
%
%   Outputs
%     faces       - F-by-4: sorted vertex triple plus the face id of the
%                   first occurrence.
%     faces_count - F-by-1 occurrence counts aligned with faces.
faces = [[sort(tetra(:,[2 4 3]),2) ones(size(tetra,1),1) [1:size(tetra,1)]'];
    [sort(tetra(:,[1 3 4]),2) 2*ones(size(tetra,1),1)  [1:size(tetra,1)]'];
    [sort(tetra(:,[1 4 2]),2) 3*ones(size(tetra,1),1)  [1:size(tetra,1)]'];
    [sort(tetra(:,[1 2 3]),2) 4*ones(size(tetra,1),1)  [1:size(tetra,1)]']];

[faces_unique, faces_ind_1, faces_ind_2] = unique(faces(:,1:3),'rows');

faces = [faces_unique faces(faces_ind_1,4)];

faces_count = accumarray(faces_ind_2,ones(size(faces_ind_2,1),1),size(faces_ind_1));

end
