classdef MeshRefinementEdgeIndexTest < matlab.unittest.TestCase
%MESHREFINEMENTEDGEINDEXTEST  Differential test for mid-edge node numbering.
%
%   zef_mesh_refinement and zef_refinement_step number the mid-edge nodes
%   created when a tetrahedron is split. Upstream did this with a sequential
%   loop carrying new_node_ind and current_edge; both were rewritten as a
%   unique/ismember pair. The numbering feeds edge_mat, which selects which
%   nodes each child tetrahedron is built from, so an off-by-one or a
%   duplicated index silently produces a corrupt mesh rather than an error -
%   and every conductivity, lead field and reconstruction downstream is then
%   wrong. This class pins the vectorised form against the upstream loop.
%
%   The upstream loop is reproduced verbatim in referenceLoop as the
%   comparison oracle; vectorisedForm mirrors the shipped code.
%
%   See also tests.smoke.SyntaxIntegrityTest.

    methods (Test)
        function matchesUpstreamLoopOnRandomInputs(testCase)
            % Both forms must agree for every input shape the callers can
            % actually produce, i.e. after sortrows(edge_ind, [1 2 5]).
            rng(20260830);
            for trial = 1:200
                edge_ind = tests.unit.MeshRefinementEdgeIndexTest.randomEdgeInd();
                expected = tests.unit.MeshRefinementEdgeIndexTest.referenceLoop(edge_ind);
                actual = tests.unit.MeshRefinementEdgeIndexTest.vectorisedForm(edge_ind);
                testCase.verifyEqual(actual, expected, ...
                    "mid-edge numbering diverged from the upstream loop on trial " + trial);
            end
        end

        function everyFlaggedEdgeGetsExactlyOneIndex(testCase)
            % Independent of upstream: the numbering must be a bijection
            % between distinct edges carrying a col-5 == 1 row and 1..N.
            rng(7);
            for trial = 1:100
                edge_ind = tests.unit.MeshRefinementEdgeIndexTest.randomEdgeInd();
                col4 = tests.unit.MeshRefinementEdgeIndexTest.vectorisedForm(edge_ind);

                flagged = unique(edge_ind(edge_ind(:,5) == 1, 1:2), 'rows');
                assigned = unique(col4(col4 > 0));
                testCase.verifyEqual(numel(assigned), size(flagged, 1), ...
                    'number of minted mid-edge nodes must equal the distinct flagged edges');
                if ~isempty(assigned)
                    testCase.verifyEqual(sort(assigned(:))', 1:numel(assigned), ...
                        'indices must be a gap-free 1..N run');
                end

                % One index per edge, and one edge per index.
                for k = assigned(:)'
                    pairs = unique(edge_ind(col4 == k, 1:2), 'rows');
                    testCase.verifyEqual(size(pairs, 1), 1, ...
                        'a single index must never be shared by two edges');
                end
            end
        end

        function unflaggedOnlyEdgesGetNoNode(testCase)
            % An edge whose rows all have col 5 ~= 1 is not being split, so
            % it must keep the 0 placeholder that the caller relies on when
            % it drops the first unique() bin.
            edge_ind = [1 2 1 0 2 1; 1 2 2 0 3 2; 3 4 3 0 1 3];
            edge_ind = sortrows(edge_ind, [1 2 5]);
            col4 = tests.unit.MeshRefinementEdgeIndexTest.vectorisedForm(edge_ind);
            unflagged = ismember(edge_ind(:,1:2), [1 2], 'rows');
            testCase.verifyEqual(col4(unflagged), zeros(nnz(unflagged), 1));
            testCase.verifyTrue(all(col4(~unflagged) > 0));
        end

        function reusesOneNodePerEdgeWhenRowsAreNotContiguous(testCase)
            % Cannot arise through the callers because they sort first, but
            % it isolates the one place the two forms differ: upstream only
            % remembers the previous edge, so a repeat of an earlier edge
            % mints a second node at the same location. The vectorised form
            % reuses the first index, which is the correct behaviour.
            edge_ind = [1 2 1 0 1 1; 3 4 2 0 1 2; 1 2 3 0 1 3];
            upstream = tests.unit.MeshRefinementEdgeIndexTest.referenceLoop(edge_ind);
            current = tests.unit.MeshRefinementEdgeIndexTest.vectorisedForm(edge_ind);
            testCase.verifyEqual(upstream, [1; 2; 3], ...
                'upstream oracle should mint a duplicate node here');
            testCase.verifyEqual(current, [1; 2; 1], ...
                'vectorised form should reuse the index already given to edge [1 2]');
        end
    end

    methods (Static)
        function edge_ind = randomEdgeInd()
            n_edges = randi([1 30]);
            n_nodes = randi([2 20]);
            rows = zeros(0, 6);
            for e = 1:n_edges
                p = sort(randperm(n_nodes, 2));
                for r = 1:randi(3)
                    rows(end+1, :) = [p(1) p(2) randi(50) 0 randi(3) randi(6)]; %#ok<AGROW>
                end
            end
            rows(:,1:2) = sort(rows(:,1:2), 2);
            edge_ind = sortrows(rows, [1 2 5]);
        end

        function col4 = referenceLoop(edge_ind)
            % Verbatim upstream m/zef_mesh_refinement.m numbering loop.
            new_node_ind = 0;
            current_edge = [0 0];
            for i = 1:size(edge_ind, 1)
                if edge_ind(i,5) == 1
                    if edge_ind(i,1:2) == current_edge
                        edge_ind(i,4) = new_node_ind;
                    else
                        new_node_ind = new_node_ind + 1;
                        current_edge = edge_ind(i,1:2);
                        edge_ind(i,4) = new_node_ind;
                    end
                else
                    if edge_ind(i,1:2) == current_edge
                        edge_ind(i,4) = new_node_ind;
                    end
                end
            end
            col4 = edge_ind(:,4);
        end

        function col4 = vectorisedForm(edge_ind)
            % Mirrors the shipped src/mesh/zef_mesh_refinement.m block.
            is_full = edge_ind(:,5) == 1;
            edge_ind(:,4) = 0;
            if any(is_full)
                [unique_full, ~] = unique(edge_ind(is_full, 1:2), 'rows', 'stable');
                [tf, loc] = ismember(edge_ind(:,1:2), unique_full, 'rows');
                edge_ind(tf,4) = loc(tf);
            end
            col4 = edge_ind(:,4);
        end
    end
end
