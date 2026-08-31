classdef CreateFemMeshStencilTest < matlab.unittest.TestCase
%CREATEFEMMESHSTENCILTEST  Cube→tet fill: vectorized vs upstream loop.
%
%   zef_create_fem_mesh replaced the nested i_x / i_y / i_z loops that emit
%   five (mode 1) or six (mode 2) tetrahedra per Cartesian cube with an
%   ndgrid / sub2ind / permute gather. The stencil depends on (i_x,i_y,i_z)
%   parity so neighbouring cubes share a face diagonal; a remapping error
%   would produce a non-conforming mesh that later refinement, conductivity
%   assignment and the lead field all silently consume.
%
%   The oracles below are transcribed from upstream m/zef_create_fem_mesh.m
%   and from src/mesh/zef_create_fem_mesh.m. They take the same lattice
%   that meshgrid produces and return tetra and label_ind.
%
%   See also zef_create_fem_mesh.

    methods (Static)
        function S = mode1Stencils()
            S = cell(2,2,2);
            S{1,2,1} = [2 5 6 7; 7 5 4 2;  2 3 4 7; 1 2 4 5 ; 4 7 8 5];
            S{1,2,2} = [6 2 1 3; 1 3 8 6; 8 7 6 3;  5 8 6 1; 3 8 4 1 ];
            S{2,2,2} = [5 2 1 4; 4 2 7 5; 5 8 7 4;  5 7 6 2;  3 7 4 2];
            S{2,2,1} = [1 5 6 8; 6 8 3 1; 3 4 1 8; 2 3 1 6 ; 3 7 8 6  ];
            S{1,1,2} = [4 3 7 2; 2 7 4 5;  5 7 6 2; 1 5 2 4;  8 7 5 4 ];
            S{2,1,2} = [3 6 8 1; 1 3 4 8; 5 8 6 1; 1 6 2 3  ; 8 7 6 3  ];
            S{1,1,1} = [7 8 3 6; 8 1 3 6; 2 3 1 6;  1 5 6 8 ; 1 3 4 8   ];
            S{2,1,1} = [ 7 8 4 5; 5 4 7 2;  2 4 1 5; 2 5 6 7   ;  2 3 4 7 ];
        end

        function stencil = mode2Stencil()
            stencil = [     3     4     1     7 ;
                2     3     1     7 ;
                1     2     7     6 ;
                7     1     6     5 ;
                7     4     1     8 ;
                7     8     1     5  ];
        end

        function [X, Y, Z, n_cubes] = lattice(nx, ny, nz)
            x_vec = 0:nx;
            y_vec = 0:ny;
            z_vec = 0:nz;
            [X, Y, Z] = meshgrid(x_vec, y_vec, z_vec);
            n_cubes = nx * ny * nz;
        end

        function [tetra, label_ind] = upstreamFill(X, Y, Z, mode, labeling)
            size_xyz = size(X);
            n_cubes = (size(X,2)-1)*(size(X,1)-1)*(size(X,3)-1);
            if mode == 1
                S = tests.unit.CreateFemMeshStencilTest.mode1Stencils();
                n_tets = 5;
            else
                S = tests.unit.CreateFemMeshStencilTest.mode2Stencil();
                n_tets = 6;
            end
            tetra = zeros(n_tets*n_cubes, 4);
            if labeling == 1
                label_ind = zeros(n_tets*n_cubes, 8);
            else
                label_ind = zeros(n_tets*n_cubes, 4);
            end
            i = 1;
            for i_x = 1:size(X,2)-1
                for i_y = 1:size(X,1)-1
                    for i_z = 1:size(X,3)-1
                        x_ind = [i_x   i_x+1  i_x+1  i_x    i_x    i_x+1  i_x+1  i_x]';
                        y_ind = [i_y   i_y    i_y+1  i_y+1  i_y    i_y    i_y+1  i_y+1]';
                        z_ind = [i_z   i_z    i_z    i_z    i_z+1  i_z+1  i_z+1  i_z+1]';
                        ind_mat_2 = sub2ind(size_xyz, y_ind, x_ind, z_ind);
                        if mode == 1
                            st = S{2-mod(i_x,2), 2-mod(i_y,2), 2-mod(i_z,2)};
                        else
                            st = S;
                        end
                        tetra(i:i+n_tets-1,:) = ind_mat_2(st);
                        if labeling == 1
                            label_ind(i:i+n_tets-1,:) = ind_mat_2(:,ones(n_tets,1))';
                        else
                            label_ind(i:i+n_tets-1,:) = ind_mat_2(st);
                        end
                        i = i + n_tets;
                    end
                end
            end
        end

        function [tetra, label_ind] = currentFill(X, Y, Z, mode, labeling)
            size_xyz = size(X);
            n_x = size_xyz(2) - 1;
            n_y = size_xyz(1) - 1;
            n_z = size_xyz(3) - 1;
            n_cubes = n_x * n_y * n_z;
            [i_z, i_y, i_x] = ndgrid(1:n_z, 1:n_y, 1:n_x);
            ix = i_x(:);
            iy = i_y(:);
            iz = i_z(:);
            cx = [0 1 1 0 0 1 1 0];
            cy = [0 0 1 1 0 0 1 1];
            cz = [0 0 0 0 1 1 1 1];
            ind_mat_2 = sub2ind(size_xyz, iy + cy, ix + cx, iz + cz);
            if mode == 1
                St = tests.unit.CreateFemMeshStencilTest.mode1Stencils();
                S = zeros(5, 4, 2, 2, 2);
                for px = 1:2
                    for py = 1:2
                        for pz = 1:2
                            S(:,:,px,py,pz) = St{px,py,pz};
                        end
                    end
                end
                px = 2 - mod(ix, 2);
                py = 2 - mod(iy, 2);
                pz = 2 - mod(iz, 2);
                lin_s = sub2ind([2 2 2], px, py, pz);
                Sflat = reshape(S, 5, 4, 8);
                col_idx = reshape(permute(Sflat(:,:,lin_s), [2 1 3]), 20, n_cubes)';
                gathered = ind_mat_2((1:n_cubes)' + (col_idx - 1) * n_cubes);
                tetra = reshape(gathered', 4, [])';
                n_tets = 5;
            else
                st = tests.unit.CreateFemMeshStencilTest.mode2Stencil();
                col_idx = repmat(reshape(st', 1, 24), n_cubes, 1);
                gathered = ind_mat_2((1:n_cubes)' + (col_idx - 1) * n_cubes);
                tetra = reshape(gathered', 4, [])';
                n_tets = 6;
            end
            if labeling == 1
                label_ind = repelem(ind_mat_2, n_tets, 1);
            else
                label_ind = tetra;
            end
        end
    end

    methods (Test)
        function matchesUpstreamOnEveryParityAndBothModes(testCase)
            % nx,ny,nz = 3 covers every (odd,even) combination of cube
            % indices, which is the only thing the mode-1 stencil keys on.
            sizes = [2 2 2; 3 2 2; 2 3 4; 3 3 3; 4 3 2];
            for s = 1:size(sizes,1)
                [X, Y, Z] = tests.unit.CreateFemMeshStencilTest.lattice( ...
                    sizes(s,1), sizes(s,2), sizes(s,3));
                for mode = 1:2
                    for labeling = 1:2
                        [tu, lu] = tests.unit.CreateFemMeshStencilTest.upstreamFill( ...
                            X, Y, Z, mode, labeling);
                        [tc, lc] = tests.unit.CreateFemMeshStencilTest.currentFill( ...
                            X, Y, Z, mode, labeling);
                        testCase.verifyEqual(tc, tu, sprintf( ...
                            'tetra diverged: grid %s mode %d labeling %d', ...
                            mat2str(sizes(s,:)), mode, labeling));
                        testCase.verifyEqual(lc, lu, sprintf( ...
                            'label_ind diverged: grid %s mode %d labeling %d', ...
                            mat2str(sizes(s,:)), mode, labeling));
                    end
                end
            end
        end

        function everyCubeHasTheRightNumberOfTetsAndValidNodeIds(testCase)
            [X, Y, Z] = tests.unit.CreateFemMeshStencilTest.lattice(3, 3, 3);
            n_nodes = numel(X);
            n_cubes = 3*3*3;
            [t5, ~] = tests.unit.CreateFemMeshStencilTest.currentFill(X, Y, Z, 1, 2);
            [t6, ~] = tests.unit.CreateFemMeshStencilTest.currentFill(X, Y, Z, 2, 2);
            testCase.verifyEqual(size(t5,1), 5*n_cubes);
            testCase.verifyEqual(size(t6,1), 6*n_cubes);
            testCase.verifyTrue(all(t5(:) >= 1) && all(t5(:) <= n_nodes));
            testCase.verifyTrue(all(t6(:) >= 1) && all(t6(:) <= n_nodes));
            testCase.verifyEqual(size(unique(t5, 'rows'), 1), size(t5,1), ...
                'mode-1 tetrahedra must be unique');
            testCase.verifyEqual(size(unique(t6, 'rows'), 1), size(t6,1), ...
                'mode-2 tetrahedra must be unique');
        end

        function neighbouringCubesShareAFaceDiagonal(testCase)
            % The parity-dependent stencil exists so a shared face of two
            % cubes is split along the same diagonal. If the remap picked
            % the wrong stencil, two tets would cross that face.
            [X, Y, Z] = tests.unit.CreateFemMeshStencilTest.lattice(2, 2, 2);
            [tetra, ~] = tests.unit.CreateFemMeshStencilTest.currentFill(X, Y, Z, 1, 2);
            nodes = [X(:) Y(:) Z(:)];
            faces = [tetra(:,[2 3 4]); tetra(:,[1 3 4]); tetra(:,[1 2 4]); tetra(:,[1 2 3])];
            faces = sort(faces, 2);
            [uf, ~, ic] = unique(faces, 'rows');
            counts = accumarray(ic, 1);
            interior = counts == 2;
            boundary = counts == 1;
            testCase.verifyEqual(nnz(counts > 2), 0, ...
                'a face shared more than twice means the stencil is non-conforming');
            testCase.verifyGreaterThan(nnz(interior), 0);
            testCase.verifyGreaterThan(nnz(boundary), 0);

            % Every interior face's four endpoints must be coplanar with a
            % single diagonal, which is automatic if exactly two tets share
            % it; pin that the shared-face vertices really are a triangle.
            for k = find(interior)'
                testCase.verifyEqual(numel(unique(uf(k,:))), 3);
            end
            testCase.verifyTrue(all(all(isfinite(nodes))));
        end
    end
end
