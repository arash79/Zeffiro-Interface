classdef MEGLoadVectorVectorizationTest < matlab.unittest.TestCase
%MEGLOADVECTORVECTORIZATIONTEST  MEG nodal load: vectorized vs upstream loop.
%
%   The magnetometer and gradiometer lead fields replaced upstream's
%   element-by-element accumulation
%
%       for b_vec_ind = 1:K2
%           b_vec(tetrahedra(b_vec_ind,i)) = b_vec(tetrahedra(b_vec_ind,i)) ...
%               + dot_vec(b_vec_ind);
%       end
%
%   with a single accumarray, hoisted the magnetometer-independent sigma*grad
%   term out of the sensor loop, and replaced dot(A,repmat(o,1,K)) and repmat
%   subtraction with implicit expansion. Accumulating duplicate indices in a
%   different order is exactly the kind of change that can perturb a lead
%   field, so the equivalence is pinned here rather than assumed.
%
%   The reference implementations below are transcribed from upstream
%   m/forward_simulation/lead_field/zef_lead_field_meg_fem.m.
%
%   See also zef_lead_field_meg_fem, zef_lead_field_meg_grad_fem.

    methods (Static)
        function [nodes, tetrahedra, sigma_tetrahedra, sensors] = fixture(nn, K2, L)
            nodes = randn(nn,3)*0.08;
            tetrahedra = randi(nn, K2, 4);
            sigma_tetrahedra = abs(randn(6,K2))*0.3 + 0.05;
            ori = randn(3,L); ori = ori ./ sqrt(sum(ori.^2,1));
            sensors = [randn(3,L)*0.12; ori];
        end

        function B = upstreamBlock(nodes, tetrahedra, sigma_tetrahedra, sensors, N, L, K2)
            ind_m = [2 3 4; 3 4 1; 4 1 2; 1 2 3];
            B = zeros(N,L);
            tetra_c = (1/4)*(nodes(tetrahedra(:,1),:)+nodes(tetrahedra(:,2),:) ...
                +nodes(tetrahedra(:,3),:)+nodes(tetrahedra(:,4),:))';
            for i = 1:4
                grad_1 = cross( ...
                    nodes(tetrahedra(:,ind_m(i,2)),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)', ...
                    nodes(tetrahedra(:,ind_m(i,3)),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)')/2;
                grad_1 = repmat(sign(dot(grad_1, ...
                    (nodes(tetrahedra(:,i),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)'))),3,1).*grad_1;
                for j = 1:L
                    cross_mat_aux = zeros(size(tetra_c));
                    cross_mat_aux(1,:) = sigma_tetrahedra(1,:).*grad_1(1,:) + sigma_tetrahedra(4,:).*grad_1(2,:) + sigma_tetrahedra(5,:).*grad_1(3,:);
                    cross_mat_aux(2,:) = sigma_tetrahedra(4,:).*grad_1(1,:) + sigma_tetrahedra(2,:).*grad_1(2,:) + sigma_tetrahedra(6,:).*grad_1(3,:);
                    cross_mat_aux(3,:) = sigma_tetrahedra(5,:).*grad_1(1,:) + sigma_tetrahedra(6,:).*grad_1(2,:) + sigma_tetrahedra(3,:).*grad_1(3,:);
                    sensor_mat_aux = repmat(sensors(1:3,j),1,size(tetra_c,2)) - tetra_c;
                    cross_mat = cross(cross_mat_aux, sensor_mat_aux);
                    power_vec = sqrt(sum(sensor_mat_aux.^2));
                    power_vec = (power_vec.^2).*power_vec;
                    dot_vec = dot(cross_mat,repmat(sensors(4:6,j),1,size(tetra_c,2)))./(3*power_vec);
                    b_vec = zeros(N,1);
                    for b_vec_ind = 1:K2
                        b_vec(tetrahedra(b_vec_ind,i)) = b_vec(tetrahedra(b_vec_ind,i)) + dot_vec(b_vec_ind);
                    end
                    B(:,j) = B(:,j) + b_vec;
                end
            end
        end

        function B = currentBlock(nodes, tetrahedra, sigma_tetrahedra, sensors, N, L)
            ind_m = [2 3 4; 3 4 1; 4 1 2; 1 2 3];
            B = zeros(N,L);
            tetra_c = (1/4)*(nodes(tetrahedra(:,1),:)+nodes(tetrahedra(:,2),:) ...
                +nodes(tetrahedra(:,3),:)+nodes(tetrahedra(:,4),:))';
            for i = 1:4
                grad_1 = cross( ...
                    nodes(tetrahedra(:,ind_m(i,2)),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)', ...
                    nodes(tetrahedra(:,ind_m(i,3)),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)')/2;
                grad_1 = repmat(sign(dot(grad_1, ...
                    (nodes(tetrahedra(:,i),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)'))),3,1).*grad_1;
                cross_mat_aux = zeros(size(tetra_c));
                cross_mat_aux(1,:) = sigma_tetrahedra(1,:).*grad_1(1,:) + sigma_tetrahedra(4,:).*grad_1(2,:) + sigma_tetrahedra(5,:).*grad_1(3,:);
                cross_mat_aux(2,:) = sigma_tetrahedra(4,:).*grad_1(1,:) + sigma_tetrahedra(2,:).*grad_1(2,:) + sigma_tetrahedra(6,:).*grad_1(3,:);
                cross_mat_aux(3,:) = sigma_tetrahedra(5,:).*grad_1(1,:) + sigma_tetrahedra(6,:).*grad_1(2,:) + sigma_tetrahedra(3,:).*grad_1(3,:);
                tet_i = tetrahedra(:,i);
                for j = 1:L
                    sensor_mat_aux = sensors(1:3,j) - tetra_c;
                    cross_mat = cross(cross_mat_aux, sensor_mat_aux);
                    power_vec = sqrt(sum(sensor_mat_aux.^2, 1));
                    power_vec = (power_vec.^2).*power_vec;
                    ori = sensors(4:6,j);
                    dot_vec = (ori(1)*cross_mat(1,:) + ori(2)*cross_mat(2,:) + ori(3)*cross_mat(3,:))./(3*power_vec);
                    B(:,j) = B(:,j) + accumarray(tet_i, dot_vec(:), [N, 1]);
                end
            end
        end
    end

    methods (Test)
        function matchesUpstreamLoopBitwise(testCase)
            % accumarray with the default sum accumulates in index order, so
            % this is bitwise rather than merely close. Asserting equality
            % exactly is deliberate: any future rewrite that perturbs the
            % summation order should surface here and be judged on purpose.
            rng(20260831);
            for trial = 1:6
                [nodes, tetrahedra, sigma, sensors] = ...
                    tests.unit.MEGLoadVectorVectorizationTest.fixture(220, 3000, 5);
                N = size(nodes,1); L = size(sensors,2); K2 = size(tetrahedra,1);
                B_up = tests.unit.MEGLoadVectorVectorizationTest.upstreamBlock( ...
                    nodes, tetrahedra, sigma, sensors, N, L, K2);
                B_cur = tests.unit.MEGLoadVectorVectorizationTest.currentBlock( ...
                    nodes, tetrahedra, sigma, sensors, N, L);
                testCase.verifyEqual(B_cur, B_up, ...
                    sprintf('MEG load vector diverged from the upstream loop on trial %d', trial));
            end
        end

        function accumarrayMatchesSequentialAccumulationUnderHeavyDuplication(testCase)
            % The property the vectorization relies on, isolated: duplicate
            % target indices and a wide dynamic range.
            rng(7);
            for trial = 1:5
                N = 400; K2 = 15000;
                idx = randi(N, K2, 1);
                vals = randn(K2,1) * 10^(randi([-8 8]));
                ref = zeros(N,1);
                for k = 1:K2
                    ref(idx(k)) = ref(idx(k)) + vals(k);
                end
                testCase.verifyEqual(accumarray(idx, vals, [N,1]), ref, ...
                    sprintf('accumarray diverged from sequential accumulation on trial %d', trial));
            end
        end

        function accumarrayIsRunToRunDeterministic(testCase)
            % A lead field must be reproducible across runs of the same input.
            rng(11);
            N = 400; K2 = 20000;
            idx = randi(N, K2, 1);
            vals = randn(K2,1);
            ref = accumarray(idx, vals, [N,1]);
            for r = 1:25
                testCase.verifyEqual(accumarray(idx, vals, [N,1]), ref, ...
                    'accumarray is not reproducible across calls');
            end
        end

        function explicitDotExpansionMatchesDotWithRepmat(testCase)
            rng(13);
            for trial = 1:5
                K = 5000;
                A = randn(3,K) * 10^(randi([-6 6]));
                o = randn(3,1); o = o/norm(o);
                testCase.verifyEqual( ...
                    o(1)*A(1,:) + o(2)*A(2,:) + o(3)*A(3,:), ...
                    dot(A, repmat(o,1,K)), ...
                    sprintf('explicit expansion diverged from dot on trial %d', trial));
            end
        end
    end
end
