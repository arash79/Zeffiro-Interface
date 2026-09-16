classdef EegLeadFieldAssemblyTest < matlab.unittest.TestCase
%EEGLEADFIELDASSEMBLYTEST  Cube PEM EEG FEM produces a finite mean-zero L.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function cubePemWhitneyIsFiniteAndMeanZero(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            nodes = zef.nodes / 1000;
            tetra = zef.tetra;
            sigma = 0.33 * ones(size(tetra, 1), 1);
            electrodes = nodes([1, size(nodes, 1)], :);
            brain_ind = (1:size(tetra, 1))';
            centroids = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) ...
                + nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;
            [~, order] = sort(sum((centroids - mean(nodes, 1)).^2, 2));
            source_ind = order(1:min(2, numel(order)));
            zef.source_model = core.types.ZefSourceModel.Whitney;
            zef.use_gpu = 0;
            zef.gpu_count = 0;
            zef.parallel_processes = 1;
            zef.processes_per_core = 1;
            lf_param = struct( ...
                "direction_mode", "cartesian", ...
                "precond", "cholinc", ...
                "pcg_tol", 1e-8, ...
                "maxit", 200);
            L = zef_lead_field_eeg_fem( ...
                zef, nodes, tetra, sigma, electrodes, [], "pbo", ...
                brain_ind, source_ind, lf_param);
            testCase.verifyEqual(size(L, 1), 2);
            testCase.verifyEqual(size(L, 2), 3 * numel(source_ind));
            testCase.verifyTrue(all(isfinite(L), "all"));
            testCase.verifyLessThanOrEqual(max(abs(mean(L, 1))), 1e-10);
        end
    end
end
