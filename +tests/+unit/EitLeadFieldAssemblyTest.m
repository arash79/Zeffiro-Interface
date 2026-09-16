classdef EitLeadFieldAssemblyTest < matlab.unittest.TestCase
%EITLEADFIELDASSEMBLYTEST  Cube CEM EIT FEM produces a finite Jacobian.
%
%   Electrodes are built from uint32 surface faces (as zef_surface_mesh
%   returns). Jacobian rows are size(current_pattern,2)*n_electrodes.
%   Type-1 DOF decomposition uses the supplied source tetra barycentra and
%   does not read n_sources from the base workspace.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function cubeCemEitIsFinite(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            nodes = zef.nodes / 1000;
            tetra = zef.tetra;
            sigma = 0.33 * ones(size(tetra, 1), 1);
            faces = zef_surface_mesh(tetra);
            testCase.assumeGreaterThanOrEqual(size(faces, 1), 2, ...
                "cube mesh has no surface triangles");
            electrodes = [ ...
                1, faces(1, :); ...
                2, faces(2, :)];
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
            zef.n_sources = numel(source_ind);
            zef.dof_decomposition_type = 1;
            zef.redo_eit_dec = 1;
            zef.current_pattern = [1; -1];
            lf_param = struct( ...
                "direction_mode", "cartesian", ...
                "precond", "cholinc", ...
                "pcg_tol", 1e-8, ...
                "maxit", 200, ...
                "impedances", [1000; 1000]);
            [L, bg] = zef_lead_field_eit_fem( ...
                zef, nodes, tetra, sigma, electrodes, [], ...
                brain_ind, source_ind, lf_param);
            testCase.verifyEqual(size(L, 1), 2);
            testCase.verifyTrue(all(isfinite(L), "all"));
            testCase.verifyGreaterThan(max(abs(L), [], "all"), 0);
            testCase.verifyEqual(numel(bg), 2);
            testCase.verifyTrue(all(isfinite(bg)));
        end
    end
end
