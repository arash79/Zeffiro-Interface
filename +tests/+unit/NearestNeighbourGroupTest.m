classdef NearestNeighbourGroupTest < matlab.unittest.TestCase
%NEARESTNEIGHBOURGROUPTEST  accumarray groups vs find(p_nn==i).
%
%   zef_hdiv_interpolation and zef_whitney_interpolation replaced
%
%       find(p_nearest_neighbour_inds == i)
%
%   inside the source loop with one accumarray that builds a cell of index
%   lists. The lists are the tetrahedra whose nearest interpolation source
%   is i; a wrong grouping would attach the wrong H(div)/Whitney stencil to
%   a source and silently move lead-field columns.
%
%   See also zef_hdiv_interpolation, zef_whitney_interpolation,
%            zef_nearest_neighbour_groups.

    methods (TestClassSetup)
        function addLeadFieldFolderToPath(testCase)
            if ~isempty(which('zef_nearest_neighbour_groups'))
                return
            end
            here = fileparts(mfilename('fullpath'));
            repo = fileparts(fileparts(here));
            testCase.applyFixture( ...
                matlab.unittest.fixtures.PathFixture( ...
                fullfile(repo, 'src', 'forward', 'lead_field')));
        end
    end

    methods (Static)
        function groups = currentGroups(p_nn, n_sources)
            groups = zef_nearest_neighbour_groups(p_nn, n_sources);
        end

        function groups = upstreamGroups(p_nn, n_sources)
            groups = cell(n_sources, 1);
            for i = 1:n_sources
                groups{i} = find(p_nn == i);
            end
        end
    end

    methods (Test)
        function matchesFindOnRandomLabels(testCase)
            rng(20260831);
            for trial = 1:40
                n_src = randi([3 80]);
                n_tet = randi([n_src, 8*n_src]);
                p_nn = randi(n_src, n_tet, 1);
                testCase.verifyEqual( ...
                    tests.unit.NearestNeighbourGroupTest.currentGroups(p_nn, n_src), ...
                    tests.unit.NearestNeighbourGroupTest.upstreamGroups(p_nn, n_src), ...
                    sprintf('nearest-neighbour groups diverged on trial %d', trial));
            end
        end

        function emptyLabelsGiveEmptyCells(testCase)
            testCase.verifyEqual( ...
                tests.unit.NearestNeighbourGroupTest.currentGroups([], 5), {});
        end

        function unusedSourcesStayEmpty(testCase)
            p_nn = [1; 1; 3; 3; 3];
            g = tests.unit.NearestNeighbourGroupTest.currentGroups(p_nn, 4);
            testCase.verifyEqual(g{1}, [1; 2]);
            testCase.verifyEqual(g{2}, zeros(0, 1));
            testCase.verifyEqual(g{3}, [3; 4; 5]);
            testCase.verifyEqual(g{4}, zeros(0, 1));
        end

        function groupMembersAreIncreasing(testCase)
            % find() returns sorted indices. accumarray must too, or the
            % later env_inds concatenation would change stencil order.
            rng(2);
            p_nn = randi(12, 200, 1);
            g = tests.unit.NearestNeighbourGroupTest.currentGroups(p_nn, 12);
            for i = 1:12
                if ~isempty(g{i})
                    testCase.verifyEqual(g{i}, sort(g{i}));
                end
            end
        end
    end
end
