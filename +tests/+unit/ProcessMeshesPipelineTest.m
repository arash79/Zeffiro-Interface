classdef ProcessMeshesPipelineTest < matlab.unittest.TestCase
%PROCESSMESHESPIPELINETEST  Cube surface → labeled tetrahedra.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function processMeshesAppliesTranslation(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef.c1_x_correction = 5;
            out = zef_process_meshes(zef);
            testCase.verifyEqual(numel(out.reuna_p), 1);
            testCase.verifyEqual(size(out.reuna_p{1}, 1), 8);
            testCase.verifyEqual(out.reuna_p{1}(:, 1), zef.c1_points(:, 1) + 5, "AbsTol", 1e-12);
            testCase.verifyEqual(out.reuna_type{1, 1}, 2);
            testCase.verifyEqual(out.reuna_type{1, 4}, 'c1');
            testCase.verifyEqual(size(out.sensors, 2), 3);
        end

        function createFemMeshFillsClosedCube(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            testCase.verifyGreaterThan(size(zef.nodes, 1), 8);
            testCase.verifyGreaterThan(size(zef.tetra, 1), 1);
            testCase.verifyEqual(size(zef.tetra, 2), 4);
            testCase.verifyEqual(numel(zef.domain_labels), size(zef.tetra, 1));
            testCase.verifyTrue(all(zef.domain_labels >= 1));
            testCase.verifyTrue(all(zef.domain_labels <= 1));
        end

        function createFemMeshMode2AlsoFillsClosedCube(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef.initial_mesh_mode = 2;
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            testCase.verifyGreaterThan(size(zef.tetra, 1), 1);
            testCase.verifyEqual(size(zef.tetra, 2), 4);
            testCase.verifyEqual(numel(zef.domain_labels), size(zef.tetra, 1));
        end
    end
end
