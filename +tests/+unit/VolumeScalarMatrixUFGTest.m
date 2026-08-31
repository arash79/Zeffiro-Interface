classdef VolumeScalarMatrixUFGTest < matlab.unittest.TestCase
%VOLUMESCALARMATRIXUFGTEST  Validate the matrix-free uFG convection kernel.
%
%   zef_volume_scalar_matrix_uFG was dropped during the reorganization while
%   zef_barycentric_weighting kept its 'uFG' case, leaving zef_nse_iteration
%   calling a kernel that existed in no tree. The kernel is restored, so it
%   needs cover: it has no other caller that could catch a mistake, and its
%   only caller has never been executable.
%
%   The oracle is an explicit dense assembly of the documented formula. It is
%   deliberately written as a triple loop over local indices accumulating into
%   a full matrix, so it shares no code path with the accumarray form under
%   test while computing the same quantity.
%
%   See also zef_volume_scalar_matrix_uFG, zef_barycentric_weighting.

    properties (Constant)
        % Unit cube split into six tetrahedra.
        Nodes = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]
        Tetra = [1 2 3 7; 1 3 4 7; 1 2 6 7; 1 5 6 7; 1 4 8 7; 1 5 8 7]
    end

    methods (Test)
        function kernelIsOnThePath(testCase)
            testCase.verifyNotEmpty(which('zef_volume_scalar_matrix_uFG'), ...
                'zef_volume_scalar_matrix_uFG must be on the path');
            testCase.verifyEmpty(which('zef_volume_scalar_uFG'), ...
                'the misspelled name must not reappear');
        end

        function nseIterationCallsTheRealKernelName(testCase)
            % The four call sites named a nonexistent function for the whole
            % life of this file, upstream included. Catch a relapse.
            f = which('zef_nse_iteration');
            testCase.assertNotEmpty(f);
            lines = splitlines(string(fileread(f)));
            code = lines(~startsWith(strtrim(lines), "%"));
            testCase.verifyFalse(any(contains(code, "zef_volume_scalar_uFG(")), ...
                'zef_nse_iteration must not call the nonexistent zef_volume_scalar_uFG');
            testCase.verifyTrue(any(contains(code, "zef_volume_scalar_matrix_uFG(")), ...
                'zef_nse_iteration should call zef_volume_scalar_matrix_uFG');
        end

        function weightsAreTheP1MassMatrixEntries(testCase)
            % V/10 on the diagonal and V/20 off it are the exact integrals of
            % products of two linear hat functions over a tetrahedron. Their
            % row sum must be 1/4 because the hats form a partition of unity,
            % which is also the FG weight.
            w = zef_barycentric_weighting('uFG');
            testCase.verifyEqual(w(1), 1/10, 'AbsTol', 0);
            testCase.verifyEqual(w(2), 1/20, 'AbsTol', 0);
            testCase.verifyEqual(w(1) + 3*w(2), zef_barycentric_weighting('FG'), ...
                'AbsTol', 1e-15);
        end

        function matchesExplicitDenseAssembly(testCase)
            rng(11);
            [nodes, tetra, b_coord, volume] = testCase.fixtureGeometry();
            n = size(nodes, 1);
            sigma = rand(size(tetra, 1), 1);
            x1 = rand(n,1); x2 = rand(n,1); x3 = rand(n,1);
            u = rand(n,1);

            for h = 1:3
                A = testCase.denseReference(nodes, tetra, b_coord, volume, sigma, u, h);
                [y1, y2, y3] = zef_volume_scalar_matrix_uFG( ...
                    nodes, tetra, h, x1, x2, x3, u, sigma, []);
                % Pure sums of products of O(1) quantities, so the two
                % summation orders may differ only in rounding.
                testCase.verifyEqual(y1, A*x1, 'RelTol', 1e-12);
                testCase.verifyEqual(y2, A*x2, 'RelTol', 1e-12);
                testCase.verifyEqual(y3, A*x3, 'RelTol', 1e-12);
            end
        end

        function isLinearInTheAppliedField(testCase)
            rng(3);
            [nodes, tetra] = testCase.fixtureGeometry();
            n = size(nodes,1);
            sigma = rand(size(tetra,1),1);
            u = rand(n,1);
            a = rand(n,1); b = rand(n,1);

            [ya, ~, ~] = zef_volume_scalar_matrix_uFG(nodes,tetra,1,a,a,a,u,sigma,[]);
            [yb, ~, ~] = zef_volume_scalar_matrix_uFG(nodes,tetra,1,b,b,b,u,sigma,[]);
            [ys, ~, ~] = zef_volume_scalar_matrix_uFG(nodes,tetra,1,a+b,a+b,a+b,u,sigma,[]);
            testCase.verifyEqual(ys, ya + yb, 'RelTol', 1e-12);
        end

        function submeshPathAgreesWithScatterGather(testCase)
            % Passing i_node_ind must equal zero-padding the inputs, running
            % over the whole mesh and then selecting those rows.
            rng(5);
            [nodes, tetra] = testCase.fixtureGeometry();
            n = size(nodes,1);
            sigma = rand(size(tetra,1),1);
            ind = [1 2 3 5 7]';
            full1 = rand(n,1); full2 = rand(n,1); full3 = rand(n,1); fullu = rand(n,1);

            padded = zeros(n,1); padded(ind) = full1(ind);
            padded2 = zeros(n,1); padded2(ind) = full2(ind);
            padded3 = zeros(n,1); padded3(ind) = full3(ind);
            paddedu = zeros(n,1); paddedu(ind) = fullu(ind);

            [sub1, sub2, sub3] = zef_volume_scalar_matrix_uFG(nodes, tetra, 2, ...
                full1(ind), full2(ind), full3(ind), fullu(ind), sigma, ind);
            [ref1, ref2, ref3] = zef_volume_scalar_matrix_uFG(nodes, tetra, 2, ...
                padded, padded2, padded3, paddedu, sigma, []);

            testCase.verifyEqual(sub1, ref1(ind), 'RelTol', 1e-12);
            testCase.verifyEqual(sub2, ref2(ind), 'RelTol', 1e-12);
            testCase.verifyEqual(sub3, ref3(ind), 'RelTol', 1e-12);
        end

        function cachedBarycentricDataGivesIdenticalResult(testCase)
            % The b_coord/volume outputs exist so later calls can skip
            % recomputing them; reusing them must change nothing at all.
            rng(9);
            [nodes, tetra] = testCase.fixtureGeometry();
            n = size(nodes,1);
            sigma = rand(size(tetra,1),1);
            x1 = rand(n,1); x2 = rand(n,1); x3 = rand(n,1); u = rand(n,1);

            [f1, f2, f3, bc, vol] = zef_volume_scalar_matrix_uFG( ...
                nodes, tetra, 2, x1, x2, x3, u, sigma, []);
            [c1, c2, c3] = zef_volume_scalar_matrix_uFG( ...
                nodes, tetra, 2, x1, x2, x3, u, sigma, [], bc, vol);

            testCase.verifyEqual(c1, f1);
            testCase.verifyEqual(c2, f2);
            testCase.verifyEqual(c3, f3);
        end
    end

    methods (Access = private)
        function [nodes, tetra, b_coord, volume] = fixtureGeometry(testCase)
            nodes = testCase.Nodes;
            tetra = testCase.Tetra;
            if nargout > 2
                % Built the same way the kernel builds it, so the reference
                % exercises the assembly rather than zef_volume_barycentric.
                b_coord = zeros(size(tetra,1), size(tetra,2), 4);
                [b_coord(:,:,1), det] = zef_volume_barycentric(nodes, tetra, 1);
                for i = 2:4
                    b_coord(:,:,i) = zef_volume_barycentric(nodes, tetra, i, det);
                end
                volume = abs(det)/6;
            end
        end

        function A = denseReference(~, nodes, tetra, b_coord, volume, sigma, u, h)
            w = zef_barycentric_weighting('uFG');
            n = size(nodes,1);
            A = zeros(n,n);
            for t = 1:size(tetra,1)
                v = tetra(t,:);
                for i = 1:4
                    for j = 1:4
                        for k = 1:4
                            if i == k
                                ww = w(1);
                            else
                                ww = w(2);
                            end
                            A(v(i), v(j)) = A(v(i), v(j)) ...
                                + ww * u(v(k)) * b_coord(t,h,j) * sigma(t) * volume(t);
                        end
                    end
                end
            end
        end
    end
end
