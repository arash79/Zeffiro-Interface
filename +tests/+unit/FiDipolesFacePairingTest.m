classdef FiDipolesFacePairingTest < matlab.unittest.TestCase
%FIDIPOLESFACEPAIRINGTEST  FI face pairing: unique-key form vs upstream.
%
%   zef_fi_dipoles replaced upstream's six sortrows passes over pairs of
%   opposite-face combinations with a single unique-key pass over all four
%   faces per tetrahedron. The result orders the source space consumed by
%   both lead fields, so a changed pair set or a changed pair order would
%   permute or drop lead-field columns.
%
%   The fixtures below are conforming Kuhn (Freudenthal) triangulations of a
%   cube grid. That matters: tetrahedra built from random integers share
%   faces more than twice, which cannot happen in a valid mesh, and would
%   make the comparison test a case neither implementation is meant to serve.
%
%   See also zef_fi_dipoles, zef_ew_dipoles.

    methods (TestClassSetup)
        function addSourceTreeToPath(testCase)
            % The pairing comparisons are self-contained, but the
            % non-manifold test calls the real zef_fi_dipoles, which only
            % resolves once src/ is on the path. PathFixture restores the
            % path afterwards, so running this class alone behaves the same
            % as running it inside the full suite.
            here = fileparts(mfilename('fullpath'));
            repo = fileparts(fileparts(here));
            % PathFixture takes a folder list, not a genpath string.
            folders = split(string(genpath(fullfile(repo, 'src'))), pathsep);
            folders = folders(strlength(folders) > 0);
            testCase.applyFixture( ...
                matlab.unittest.fixtures.PathFixture(cellstr(folders)));
        end
    end

    methods (Static)
        function [nodes, tetra] = kuhnMesh(n)
            % Conforming triangulation: every interior face is shared by
            % exactly two tetrahedra, every boundary face by one.
            [X, Y, Z] = ndgrid(0:n, 0:n, 0:n);
            nodes = [X(:) Y(:) Z(:)];
            id = reshape(1:numel(X), size(X));
            tets_local = [1 2 4 8; 1 2 6 8; 1 3 4 8; 1 3 7 8; 1 5 6 8; 1 5 7 8];
            tetra = zeros(6*n^3, 4);
            c = 0;
            for k = 1:n
                for j = 1:n
                    for i = 1:n
                        corner = zeros(1,8);
                        for b = 0:7
                            dx = bitand(b,1);
                            dy = bitshift(bitand(b,2),-1);
                            dz = bitshift(bitand(b,4),-2);
                            corner(b+1) = id(i+dx, j+dy, k+dz);
                        end
                        for t = 1:6
                            c = c + 1;
                            tetra(c,:) = corner(tets_local(t,:));
                        end
                    end
                end
            end
        end

        function stf = upstreamPairs(tetrahedra, brain_ind)
            % Transcribed from upstream
            % m/forward_simulation/lead_field/zef_fi_dipoles.m.
            nb = length(brain_ind);
            Ind_cell = cell(1,3);
            for node_i = 1:4
                f1 = sort(tetrahedra(brain_ind, setdiff(1:4, node_i)), 2);
                for node_j = node_i+1:4
                    f2 = sort(tetrahedra(brain_ind, setdiff(1:4, node_j)), 2);
                    s = sortrows([ ...
                        f1 brain_ind(:) node_i*ones(nb,1) ; ...
                        f2 brain_ind(:) node_j*ones(nb,1) ]);
                    if isempty(s)
                        Ind_cell{node_i}{node_j} = zeros(0,4);
                        continue
                    end
                    I = find(0 == sum(abs(s(1:end-1,1:3) - s(2:end,1:3)), 2));
                    Ind_cell{node_i}{node_j} = [s(I,4) s(I+1,4) s(I,5) s(I+1,5)];
                end
            end
            stf = [Ind_cell{1}{2}; Ind_cell{1}{3}; Ind_cell{1}{4}; ...
                Ind_cell{2}{3}; Ind_cell{2}{4}; Ind_cell{3}{4}];
            if isempty(stf)
                stf = zeros(0,4);
                return
            end
            [~, I] = unique(stf(:,1:2), 'rows');
            stf = stf(I,:);
        end

        function stf = currentPairs(tetrahedra, brain_ind)
            stf = zef_fi_shared_faces(tetrahedra, brain_ind);
        end
    end

    methods (Test)
        function matchesUpstreamOnConformingMeshes(testCase)
            % Exact equality, including pair order: the row order fixes the
            % order of source_locations/directions and therefore the column
            % order of the FI lead field.
            for n = 2:5
                [~, tetra] = tests.unit.FiDipolesFacePairingTest.kuhnMesh(n);
                bi = (1:size(tetra,1))';
                testCase.verifyEqual( ...
                    tests.unit.FiDipolesFacePairingTest.currentPairs(tetra, bi), ...
                    tests.unit.FiDipolesFacePairingTest.upstreamPairs(tetra, bi), ...
                    sprintf('FI face pairing diverged on a %d^3 Kuhn mesh', n));
            end
        end

        function matchesUpstreamOnPartialBrainSubsets(testCase)
            % A brain subset turns interior faces into boundary faces, the
            % case where a multiplicity rule can go wrong.
            rng(4242);
            [~, tetra] = tests.unit.FiDipolesFacePairingTest.kuhnMesh(4);
            nt = size(tetra,1);
            for trial = 1:8
                bi = sort(randsample(nt, round(nt*0.6)));
                testCase.verifyEqual( ...
                    tests.unit.FiDipolesFacePairingTest.currentPairs(tetra, bi), ...
                    tests.unit.FiDipolesFacePairingTest.upstreamPairs(tetra, bi), ...
                    sprintf('FI face pairing diverged on brain subset trial %d', trial));
            end
        end

        function handlesDegenerateBrainSets(testCase)
            [~, tetra] = tests.unit.FiDipolesFacePairingTest.kuhnMesh(2);
            cases = {zeros(0,1), [1], [1;2]};
            names = {'empty brain_ind', 'single tetrahedron', 'two tetrahedra'};
            for c = 1:numel(cases)
                testCase.verifyEqual( ...
                    tests.unit.FiDipolesFacePairingTest.currentPairs(tetra, cases{c}), ...
                    tests.unit.FiDipolesFacePairingTest.upstreamPairs(tetra, cases{c}), ...
                    names{c});
            end
        end

        function everyPairSharesAFaceAndIsOrderedAndUnique(testCase)
            % Independent structural check that does not consult upstream:
            % each reported pair must genuinely share three nodes, the tet
            % indices must be ascending, and no pair may repeat.
            [~, tetra] = tests.unit.FiDipolesFacePairingTest.kuhnMesh(4);
            bi = (1:size(tetra,1))';
            stf = tests.unit.FiDipolesFacePairingTest.currentPairs(tetra, bi);
            testCase.assertNotEmpty(stf);

            testCase.verifyTrue(all(stf(:,1) < stf(:,2)), ...
                'tetrahedron indices in a pair must be ascending');
            testCase.verifyEqual(size(unique(stf(:,1:2),'rows'),1), size(stf,1), ...
                'pairs must be unique');

            for r = 1:size(stf,1)
                shared = intersect(tetra(stf(r,1),:), tetra(stf(r,2),:));
                testCase.verifyEqual(numel(shared), 3, ...
                    sprintf('pair %d does not share exactly one face', r));
                % The recorded opposite-vertex slots must be the nodes NOT
                % on the shared face, since the dipole spans those two.
                testCase.verifyFalse(ismember(tetra(stf(r,1), stf(r,3)), shared), ...
                    sprintf('pair %d: opposite vertex of the first tet lies on the shared face', r));
                testCase.verifyFalse(ismember(tetra(stf(r,2), stf(r,4)), shared), ...
                    sprintf('pair %d: opposite vertex of the second tet lies on the shared face', r));
            end
        end

        function productionDipolesMatchSharedFaces(testCase)
            [nodes, tetra] = tests.unit.FiDipolesFacePairingTest.kuhnMesh(3);
            bi = (1:size(tetra, 1))';
            [~, ~, ~, ~, locs, n_pairs] = zef_fi_dipoles(nodes, tetra, bi);
            stf = zef_fi_shared_faces(tetra, bi);
            testCase.verifyEqual(n_pairs, size(stf, 1));
            testCase.verifyEqual(size(locs, 1), n_pairs);
        end

        function nonManifoldFacesAreSkippedWithAWarning(testCase)
            % Duplicated elements make a face 4-way shared. No FI dipole is
            % defined there, but the caller must be told rather than quietly
            % receiving fewer sources.
            [nodes, tetra] = tests.unit.FiDipolesFacePairingTest.kuhnMesh(2);
            tetra_dup = [tetra; tetra(1:3,:)];
            bi = (1:size(tetra_dup,1))';

            testCase.verifyWarning( ...
                @() zef_fi_dipoles(nodes, tetra_dup, bi), ...
                'zef_fi_dipoles:nonManifoldFaces');

            % And a clean mesh must stay silent.
            testCase.verifyWarningFree( ...
                @() zef_fi_dipoles(nodes, tetra, (1:size(tetra,1))'));
        end
    end
end
