function zef = zef_merge_surface_mesh(zef,compartment_tag,triangles,points,varargin)
%ZEF_MERGE_SURFACE_MESH  Append or replace zef.<tag>_points / _triangles.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by zef_import_segmentation when a compartment already has geometry
%   and the import should concatenate a new patch (unique vertex merge, face
%   indices remapped, submesh_ind extended with the new last-face index).
%   If merge is false the existing mesh is discarded and submesh_ind is
%   just size(triangles,1).
%
%   zef = zef_merge_surface_mesh(zef, compartment_tag, triangles, points)
%   zef = zef_merge_surface_mesh(zef, compartment_tag, triangles, points, merge)
%
%   Inputs
%     zef             - session. Empty → evalin('base','zef',zef) (the extra
%                       argument is ignored by evalin).
%     compartment_tag - char/string, e.g. 'd1'. Reads/writes
%                       zef.<tag>_points, _triangles, _submesh_ind, _merge.
%     triangles       - F×3 1-based indices into points.
%     points          - V×3.
%     merge           - optional logical. Default zef.<tag>_merge.
%
%   Output
%     zef  - updated session. If nargout==0 the code calls assign('base',...)
%            (not assignin); callers that care about the base workspace
%            should capture the output.
%
%   See also zef_process_meshes, zef_import_segmentation.

if isempty(zef)
    zef = evalin('base','zef',zef);
end

if not(isempty(varargin))
    merge = varargin{1};
else
    merge = eval(['zef.' compartment_tag '_merge;']);
end

triangles_0 = eval(['zef.' compartment_tag '_triangles;']);
points_0 = eval(['zef.' compartment_tag '_points;']);
submesh_ind_0 = eval(['zef.' compartment_tag '_submesh_ind;']);

if merge

    % Unique rows of [old; new]; remap both triangle blocks through ind_aux.
    [points,~,ind_aux] = unique([points_0 ; points],'rows');
    triangles = ind_aux([triangles_0; triangles + size(points_0,1)]);
    submesh_ind = [submesh_ind_0 size(triangles,1)];

else

    submesh_ind = [size(triangles,1)];

end

eval(['zef.' compartment_tag '_points = points;']);
eval(['zef.' compartment_tag '_triangles = triangles;']);
eval(['zef.' compartment_tag '_submesh_ind = submesh_ind;']);

if nargout == 0
    assign('base','zef',zef);
end

end
