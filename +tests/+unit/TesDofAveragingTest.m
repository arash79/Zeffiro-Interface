classdef TesDofAveragingTest < matlab.unittest.TestCase
%TESDOFAVERAGINGTEST  TES current-density DOF average: sparse vs loop.
%
%   zef_lead_field_tes_fem replaced the two loops that scatter each source
%   tetra's current-density triplet into L_tes(3*(dof-1)+1:3*dof,:) and then
%   divide by dof_count with a single sparse incidence matrix times the
%   three component blocks. Several tetra can share a DOF, so this is a
%   shared-array accumulation: a wrong incidence or a swapped stride would
%   mix Cartesian components or average the wrong group.
%
%   The upstream oracle is transcribed from
%   m/forward_simulation/lead_field/zef_lead_field_tes_fem.m. The current
%   form is zef_average_tes_dof_current, which zef_lead_field_tes_fem calls.
%
%   See also zef_lead_field_tes_fem, zef_decompose_dof_space,
%            zef_average_tes_dof_current.

    methods (TestClassSetup)
        function addLeadFieldFolderToPath(testCase)
            if ~isempty(which('zef_average_tes_dof_current'))
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
        function [dof_ind, dof_count, R1, R2, R3] = fixture(K, K3, L)
            dof_ind = randi(K3, K, 1);
            dof_count = accumarray(dof_ind, 1, [K3, 1]);
            % The real caller never emits a DOF with count 0; keep that
            % contract so we test averaging, not division-by-zero.
            empty = find(dof_count == 0);
            if ~isempty(empty)
                dof_ind(1:numel(empty)) = empty;
                dof_count = accumarray(dof_ind, 1, [K3, 1]);
            end
            R1 = randn(K, L);
            R2 = randn(K, L);
            R3 = randn(K, L);
        end

        function L = upstreamAverage(dof_ind, dof_count, R1, R2, R3)
            K = numel(dof_ind);
            K3 = numel(dof_count);
            Lch = size(R1, 2);
            L = zeros(3*K3, Lch);
            for i = 1:K
                L(3*(dof_ind(i)-1)+1,:) = L(3*(dof_ind(i)-1)+1,:) + R1(i,:);
                L(3*(dof_ind(i)-1)+2,:) = L(3*(dof_ind(i)-1)+2,:) + R2(i,:);
                L(3*(dof_ind(i)-1)+3,:) = L(3*(dof_ind(i)-1)+3,:) + R3(i,:);
            end
            for i = 1:K3
                L(3*(i-1)+1,:) = L(3*(i-1)+1,:) / dof_count(i);
                L(3*(i-1)+2,:) = L(3*(i-1)+2,:) / dof_count(i);
                L(3*(i-1)+3,:) = L(3*(i-1)+3,:) / dof_count(i);
            end
        end

        function L = currentAverage(dof_ind, dof_count, R1, R2, R3)
            L = zef_average_tes_dof_current(dof_ind, dof_count, R1, R2, R3);
        end
    end

    methods (Test)
        function matchesUpstreamLoopBitwise(testCase)
            % Sparse(dof_ind, 1:K, 1) * R sums in increasing source index,
            % which is the same order as the upstream for-i=1:K loop, so
            % this is bitwise rather than merely close.
            rng(20260831);
            shapes = [20 8 5; 80 30 3; 200 50 7; 1 1 1; 15 15 4];
            for s = 1:size(shapes,1)
                [dof_ind, dof_count, R1, R2, R3] = ...
                    tests.unit.TesDofAveragingTest.fixture( ...
                    shapes(s,1), shapes(s,2), shapes(s,3));
                Lu = tests.unit.TesDofAveragingTest.upstreamAverage( ...
                    dof_ind, dof_count, R1, R2, R3);
                Lc = tests.unit.TesDofAveragingTest.currentAverage( ...
                    dof_ind, dof_count, R1, R2, R3);
                testCase.verifyEqual(Lc, Lu, sprintf( ...
                    'TES DOF average diverged on shape K=%d K3=%d L=%d', ...
                    shapes(s,1), shapes(s,2), shapes(s,3)));
            end
        end

        function oneToOneDofsAreUnchanged(testCase)
            % When every tetra is its own DOF the average is the identity.
            rng(3);
            K = 12; L = 4;
            dof_ind = (1:K)';
            dof_count = ones(K,1);
            R1 = randn(K,L); R2 = randn(K,L); R3 = randn(K,L);
            Lc = tests.unit.TesDofAveragingTest.currentAverage( ...
                dof_ind, dof_count, R1, R2, R3);
            expected = zeros(3*K, L);
            expected(1:3:end,:) = R1;
            expected(2:3:end,:) = R2;
            expected(3:3:end,:) = R3;
            testCase.verifyEqual(Lc, expected);
        end

        function twoTetsSharingADofAverageTheirTriplets(testCase)
            % Independent of the loop: two sources mapped to DOF 1, one to
            % DOF 2, must produce the arithmetic mean on DOF 1.
            R1 = [1 2; 3 4; 10 20];
            R2 = [5 6; 7 8; 30 40];
            R3 = [9 0; 1 2; 50 60];
            dof_ind = [1; 1; 2];
            dof_count = [2; 1];
            Lc = tests.unit.TesDofAveragingTest.currentAverage( ...
                dof_ind, dof_count, R1, R2, R3);
            testCase.verifyEqual(Lc(1,:), (R1(1,:) + R1(2,:))/2);
            testCase.verifyEqual(Lc(2,:), (R2(1,:) + R2(2,:))/2);
            testCase.verifyEqual(Lc(3,:), (R3(1,:) + R3(2,:))/2);
            testCase.verifyEqual(Lc(4,:), R1(3,:));
            testCase.verifyEqual(Lc(5,:), R2(3,:));
            testCase.verifyEqual(Lc(6,:), R3(3,:));
        end

        function cartesianStridesDoNotCross(testCase)
            % A regression that would look "almost right": writing the x
            % block into 2:3:end would mix components without changing
            % norms much. Pin the mapping explicitly.
            R1 = ones(4,2); R2 = 2*ones(4,2); R3 = 3*ones(4,2);
            dof_ind = (1:4)'; dof_count = ones(4,1);
            Lc = tests.unit.TesDofAveragingTest.currentAverage( ...
                dof_ind, dof_count, R1, R2, R3);
            testCase.verifyEqual(Lc(1:3:end,:), R1);
            testCase.verifyEqual(Lc(2:3:end,:), R2);
            testCase.verifyEqual(Lc(3:3:end,:), R3);
        end
    end
end
