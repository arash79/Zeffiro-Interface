function sorted_tetra_faces = zef_fi_shared_faces(tetrahedra, brain_ind)
%ZEF_FI_SHARED_FACES  Brain tetra pairs that share exactly one face.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   stf = zef_fi_shared_faces(tetrahedra, brain_ind)
%
%   Each row is [tet_a tet_b opp_a opp_b] with tet_a < tet_b. opp_* is the
%   local vertex (1..4) opposite the shared face. Faces with one incidence
%   are brain-boundary and silent. Faces with more than two incidences are
%   non-manifold: they are skipped and a warning is issued.
%
%   See also zef_fi_dipoles.

if isempty(brain_ind)
    sorted_tetra_faces = zeros(0, 4);
    return
end

n_of_tetra_in_brain = length(brain_ind);
face_opp = [
    2 3 4
    1 3 4
    1 2 4
    1 2 3
    ];
keys = zeros(4 * n_of_tetra_in_brain, 3);
owners = zeros(4 * n_of_tetra_in_brain, 1);
opp = zeros(4 * n_of_tetra_in_brain, 1);
for f = 1:4
    sl = (f - 1) * n_of_tetra_in_brain + (1:n_of_tetra_in_brain);
    keys(sl, :) = sort(tetrahedra(brain_ind, face_opp(f, :)), 2);
    owners(sl) = brain_ind;
    opp(sl) = f;
end
[~, ~, ic] = unique(keys, 'rows');
counts = accumarray(ic, 1);

n_non_manifold = nnz(counts > 2);
if n_non_manifold > 0
    warning('zef_fi_dipoles:nonManifoldFaces', ...
        ['%d face(s) of the brain submesh are shared by more than two ' ...
        'tetrahedra, so no face-interior dipole is defined there and ' ...
        'they are skipped. Check the mesh for duplicated or ' ...
        'overlapping elements.'], n_non_manifold);
end

row_ok = counts(ic) == 2;
ic_s = ic(row_ok);
owners_s = owners(row_ok);
opp_s = opp(row_ok);
[~, ord] = sort(ic_s);
owners_s = owners_s(ord);
opp_s = opp_s(ord);
a = owners_s(1:2:end);
b = owners_s(2:2:end);
oa = opp_s(1:2:end);
ob = opp_s(2:2:end);
swap = a > b;
tmp = a(swap); a(swap) = b(swap); b(swap) = tmp;
tmp = oa(swap); oa(swap) = ob(swap); ob(swap) = tmp;
[~, Iu] = unique([a b], 'rows');
sorted_tetra_faces = [a(Iu) b(Iu) oa(Iu) ob(Iu)];

end
