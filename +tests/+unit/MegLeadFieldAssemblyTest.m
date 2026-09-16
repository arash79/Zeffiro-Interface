classdef MegLeadFieldAssemblyTest < matlab.unittest.TestCase
%MEGLEADFIELDASSEMBLYTEST  Cube magnetometer FEM produces a finite L.
%
%   Cartesian MEG keeps only sources whose Whitney occupancy is at least 4
%   (zef.surface_sources==0). Column count is therefore 3*M2 with M2 at
%   most numel(source_ind), not necessarily equal to it.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function cubeMagnetometerWhitneyIsFinite(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            nodes = zef.nodes / 1000;
            tetra = zef.tetra;
            sigma = 0.33 * ones(size(tetra, 1), 1);
            sensors = [ ...
                min(nodes, [], 1) + [0 0 0.02], 0 0 1; ...
                max(nodes, [], 1) + [0 0 0.02], 0 0 1];
            brain_ind = (1:size(tetra, 1))';
            centroids = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) ...
                + nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;
            [~, order] = sort(sum((centroids - mean(nodes, 1)).^2, 2));
            source_ind = order(1:min(2, numel(order)));
            zef.source_model = core.types.ZefSourceModel.Whitney;
            zef.surface_sources = 0;
            zef.use_gpu = 0;
            zef.gpu_count = 0;
            zef.parallel_processes = 1;
            zef.processes_per_core = 1;
            lf_param = struct( ...
                "direction_mode", "cartesian", ...
                "precond", "cholinc", ...
                "pcg_tol", 1e-8, ...
                "maxit", 200);
            L = zef_lead_field_meg_fem( ...
                zef, nodes, tetra, sigma, sensors, [], ...
                brain_ind, source_ind, lf_param);
            testCase.verifyEqual(size(L, 1), 2);
            testCase.verifyGreaterThan(size(L, 2), 0);
            testCase.verifyEqual(mod(size(L, 2), 3), 0);
            testCase.verifyLessThanOrEqual(size(L, 2), 3 * numel(source_ind));
            testCase.verifyTrue(all(isfinite(L), "all"));
            testCase.verifyGreaterThan(max(abs(L), [], "all"), 0);
        end
    end
end
