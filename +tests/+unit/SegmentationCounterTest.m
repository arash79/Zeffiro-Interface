classdef SegmentationCounterTest < matlab.unittest.TestCase
%SEGMENTATIONCOUNTERTEST  Active-compartment index vs the old script.
%
%   The expected values were read from zef_segmentation_counter_step while
%   it was still a caller-workspace script, on the synthetic cube after
%   zef_process_meshes. Off compartments and a second source compartment
%   are checked against that same indexing rule.

    methods (Test)
        function cubeMatchesScriptOracle(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef = zef_process_meshes(zef);
            ctx = zef_segmentation_counter_step(zef);
            testCase.verifyEqual(ctx.mesh_res, 10);
            testCase.verifyEqual(ctx.reuna_type, {2, 'Unconstrained field', 1, 'c1'});
            testCase.verifyEqual(ctx.pml_ind_aux, []);
            testCase.verifyEqual(ctx.submesh_cell, {12});
            testCase.verifyEqual(ctx.aux_active_compartment_ind, 1);
            testCase.verifyEqual(ctx.name_tags, {'cube'});
            testCase.verifyEqual(ctx.submesh_ind_1, 1);
            testCase.verifyEqual(ctx.submesh_ind_2, 1);
        end

        function skipsOffCompartmentAndKeepsPml(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef.compartment_tags = {'c1', 'c_off', 'c_pml', 'c_src'};
            zef.c_off_on = 0;
            zef.c_off_name = 'off';
            zef.c_off_sources = 0;
            zef.c_pml_on = 1;
            zef.c_pml_name = 'box';
            zef.c_pml_sources = -1;
            zef.c_src_on = 1;
            zef.c_src_name = 'brain';
            zef.c_src_sources = 1;
            zef.reuna_p = {zeros(1, 3), zeros(1, 3), zeros(1, 3)};
            zef.reuna_submesh_ind = {[], [1 1], 4};
            zef.reuna_type = cell(3, 4);
            ctx = zef_segmentation_counter_step(zef);
            testCase.verifyEqual(ctx.name_tags, {'cube', 'box', 'brain'});
            testCase.verifyEqual(ctx.pml_ind_aux, 2);
            testCase.verifyEqual(ctx.aux_active_compartment_ind, [1 3]);
            testCase.verifyEqual(ctx.submesh_ind_1, [1; 2; 2; 3]);
            testCase.verifyEqual(ctx.submesh_ind_2, [1; 1; 2; 1]);
        end
    end
end
