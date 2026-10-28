classdef MeshLabelingStepTest < matlab.unittest.TestCase
%MESHLABELINGSTEPTEST  Labeling outputs match the pre-function script.
%
%   zef_mesh_labeling_step used to be a script that wrote tetra, nodes,
%   domain_labels, distance_vec, and label_ind into the caller workspace.
%   The reference file was captured from that script. These tests call the
%   function (through zef_create_fem_mesh, and directly for flags 2 and 3)
%   and require the same arrays.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function initialLabelingMatchesReference(testCase)
            ref = tests.unit.MeshLabelingStepTest.reference();
            zef = tests.unit.MeshLabelingStepTest.baseSession();
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.MeshLabelingStepTest.assertSessionMesh(testCase, zef, ref.default);
        end

        function mode2LabelingMatchesReference(testCase)
            ref = tests.unit.MeshLabelingStepTest.reference();
            zef = tests.unit.MeshLabelingStepTest.baseSession();
            zef.initial_mesh_mode = 2;
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.MeshLabelingStepTest.assertSessionMesh(testCase, zef, ref.mode2);
        end

        function priorityMode3MatchesReference(testCase)
            ref = tests.unit.MeshLabelingStepTest.reference();
            zef = tests.unit.MeshLabelingStepTest.baseSession();
            zef.priority_mode = 3;
            zef.mesh_relabeling = 1;
            zef.c1_labeling_priority = 1;
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.MeshLabelingStepTest.assertSessionMesh(testCase, zef, ref.priority3);
        end

        function relabelFlagsMatchScriptOracle(testCase)
            ref = tests.unit.MeshLabelingStepTest.reference();
            zef = tests.unit.MeshLabelingStepTest.baseSession();
            zef.distance_smoothing_on = 0;
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);

            zef.priority_mode = 3;
            zef.c1_labeling_priority = 1;
            zef.extensive_relabeling = 0;
            flagged = tests.unit.MeshLabelingStepTest.applyFlag(zef, 2);
            tests.unit.MeshLabelingStepTest.assertFlaggedMesh(testCase, flagged, ref.flag2);

            zef.priority_mode = 1;
            flagged = tests.unit.MeshLabelingStepTest.applyFlag(zef, 3);
            tests.unit.MeshLabelingStepTest.assertFlaggedMesh(testCase, flagged, ref.flag3);
        end
    end

    methods (Static)
        function ref = reference()
            here = fileparts(mfilename('fullpath'));
            loaded = load(fullfile(here, '..', '+support', 'mesh_labeling_reference.mat'));
            ref = loaded.cases;
        end

        function zef = baseSession()
            zef = tests.support.createSyntheticMeshZef();
            zef.feature_refinement_on = 0;
            zef.extensive_relabeling = 0;
        end

        function out = applyFlag(zef, labeling_flag)
            h = zef_waitbar(0, 1, 'relabel');
            cleanup = onCleanup(@() zef_close_waitbar(h)); %#ok<NASGU>
            [out.tetra, out.nodes, out.domain_labels, out.distance_vec, out.label_ind] = ...
                zef_mesh_labeling_step(zef, zef.tetra, zef.nodes, uint32(zef.tetra), ...
                labeling_flag, zef.domain_labels, zef.reuna_distance_vec, h);
        end

        function assertSessionMesh(testCase, zef, expected)
            testCase.verifyEqual(zef.nodes, expected.nodes);
            testCase.verifyEqual(zef.tetra, expected.tetra);
            testCase.verifyEqual(zef.domain_labels, expected.domain_labels);
            testCase.verifyEqual(zef.reuna_distance_vec, expected.reuna_distance_vec);
            testCase.verifyEqual(zef.name_tags, expected.name_tags);
        end

        function assertFlaggedMesh(testCase, actual, expected)
            testCase.verifyEqual(actual.nodes, expected.nodes);
            testCase.verifyEqual(actual.tetra, expected.tetra);
            testCase.verifyEqual(actual.domain_labels, expected.domain_labels);
            testCase.verifyEqual(actual.distance_vec, expected.distance_vec);
            testCase.verifyEqual(actual.label_ind, expected.label_ind);
        end
    end
end
