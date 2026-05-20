%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [nodes,tetrahedra,sigma,brain_ind,surface_triangles] = zef_import(void)
% --- Zeffiro documentation header ---
% zef_import — Loads external data or a saved Zeffiro project into `zef`.
%
% Purpose:
%   Loads external data or a saved Zeffiro project into `zef`.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   void
%
% Outputs:
%   nodes
%   tetrahedra
%   sigma
%   brain_ind
%   surface_triangles
%
% Zef fields (observed):
%   zef.nodes (read)
%   zef.save_file_path (read)
%   zef.tetrahedra (read)
%
% Calls (project):
%   zef_import
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[[nodes, tetrahedra, sigma]] = zef_import(void)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if not(isempty(evalin('base','zef.save_file_path'))) & not(evalin('base','zef.save_file_path')==0)
    [file file_path] = uigetfile('*.mat','Import volume data',evalin('base','zef.save_file_path'));
else
    [file file_path] = uigetfile('*.mat','Import volume data');
end
surface_triangles = [];
nodes = [];
tetrahedra = [];
sigma = [];
brain_ind = [];
if not(isequal(file,0));
    load([file_path file]);
    surface_triangles = 1;

    ind_m = [ 2 4 3 ;
        1 3 4 ;
        1 4 2 ;
        1 2 3 ];

    tetra_sort = [tetrahedra(:,[2 4 3]) ones(size(tetrahedra,1),1) [1:size(tetrahedra,1)]';
        tetrahedra(:,[1 3 4]) 2*ones(size(tetrahedra,1),1) [1:size(tetrahedra,1)]';
        tetrahedra(:,[1 4 2]) 3*ones(size(tetrahedra,1),1) [1:size(tetrahedra,1)]';
        tetrahedra(:,[1 2 3]) 4*ones(size(tetrahedra,1),1) [1:size(tetrahedra,1)]';];
    tetra_sort(:,1:3) = sort(tetra_sort(:,1:3),2);
    tetra_sort = sortrows(tetra_sort,[1 2 3]);
    tetra_ind = zeros(size(tetra_sort,1),1);
    I = find(sum(abs(tetra_sort(2:end,1:3)-tetra_sort(1:end-1,1:3)),2)==0);
    tetra_ind(I) = 1;
    tetra_ind(I+1) = 1;
    I = find(tetra_ind == 0);
    tetra_ind = sub2ind(size(tetrahedra),repmat(tetra_sort(I,5),1,3),ind_m(tetra_sort(I,4),:));
    surface_triangles = tetrahedra(tetra_ind);
    % trep = TriRep(zef.tetrahedra, zef.nodes);
    % surface_triangles = freeBoundary(trep);
    % clear trep;
end
