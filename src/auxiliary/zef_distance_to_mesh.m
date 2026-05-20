function distance_vec = zef_distance_to_mesh(p,nodes,triangles)
% --- Zeffiro documentation header ---
% zef_distance_to_mesh — Zef distance to mesh.
%
% Purpose:
%   Zef distance to mesh.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   p
%   nodes
%   triangles
%
% Outputs:
%   distance_vec
%
% Calls (project):
%   zef_distance_to_mesh
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[distance_vec] = zef_distance_to_mesh(p, nodes, triangles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


nodes = nodes';
c = nodes(:,triangles(:,1));
p = p';

v_1 = nodes(:,triangles(:,2))-nodes(:,triangles(:,1));
v_2 = nodes(:,triangles(:,3))-nodes(:,triangles(:,1));
v_3 = cross(v_1,v_2);
v_3 = v_3./repmat(sqrt(sum(v_3.^2)),3,1);

distance_vec = zeros(1,size(p,2));

for i = 1 : size(p,2)

    k = p(:,i*ones(1,size(c,2))) - c;
    s = sum(k.*v_3);
    t = k - s([1 1 1],:).*v_3;

    a = sum(v_1.*v_1);
    b = sum(v_2.*v_1);
    d = sum(v_2.*v_2);

    m = a.*d - b.*b;

    f = sum(t.*v_1);
    g = sum(t.*v_2);

    lambda_1 = (d.*f - b.*g)./m;
    lambda_2 = (-b.*f + a.*g)./m;

    I_1 = intersect(find(lambda_1 < 1),find(lambda_1 >0));
    I_2 = intersect(find(lambda_2 < 1),find(lambda_2 >0));

    I = intersect(I_1,I_2);

    z = min(abs(s(I)));
    distance_vec(i) = min(sqrt(sum((nodes - p(:,i*ones(1,size(nodes,2)))).^2)));
    if not(isempty(z))
        distance_vec(i) = min(z,distance_vec(i));
    end
end

end
