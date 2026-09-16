function [tetra,labels_tetra] = zef_hexa_to_tetra(hexa,varargin)
%ZEF_HEXA_TO_TETRA  Split each 8-node hexahedron into six tetrahedra.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same local stencil as the mode-2 lattice in zef_create_fem_mesh
%   (no parity flip). Used by utilities.duneuro2zef.convert
%   when DUNEuro supplies hexahedral elements.
%
%   [tetra, labels_tetra] = zef_hexa_to_tetra(hexa)
%   [tetra, labels_tetra] = zef_hexa_to_tetra(hexa, labels_hexa)
%
%   Inputs
%     hexa         - H×8 1-based node indices. Column order must match the
%                    stencil (corners 1–4 bottom, 5–8 top in the usual
%                    structured numbering).
%     labels_hexa  - optional H×1, copied to all six children of that cube.
%
%   Outputs
%     tetra         - (6H)×4.
%     labels_tetra  - (6H)×1 if labels were given, otherwise unset.
%
%   Notes
%     The loop body contains `i = i + 6`, which MATLAB's for-loop then
%     overwrites on the next iteration; it does not skip cubes.
%
%   See also zef_create_fem_mesh.

labels_hexa = [];
h = zef_waitbar(0,1,'Mesh conversion.');
if not(isempty(varargin))
    labels_hexa = varargin{1};
end

n_cubes = size(hexa,1);

ind_mat_1 = [     3     4     1     7 ;
    2     3     1     7 ;
    1     2     7     6 ;
    7     1     6     5 ;
    7     4     1     8 ;
    7     8     1     5  ];

tetra = zeros(6*n_cubes,4);
if not(isempty(labels_hexa))
    labels_tetra = zeros(6*n_cubes,1);
end

for i = 1 : n_cubes

    if mod(i,ceil(n_cubes/100))==0
        zef_waitbar(i,n_cubes,h,'Mesh conversion.');
    end

    tetra(6*(i-1)+1:6*i,:) = reshape(hexa(i,ind_mat_1),6,4);
    if not(isempty(labels_hexa))
        labels_tetra(6*(i-1)+1:6*i) = labels_hexa(i)*ones(6,1);
    end
    % No-op: the for-loop counter is reset to i+1 on the next iteration.
    i = i + 6;

end

zef_close_waitbar(h)

end
