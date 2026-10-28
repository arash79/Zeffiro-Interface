classdef CompartmentInclusionTest < matlab.unittest.TestCase
%COMPARTMENTINCLUSIONTEST  Solid-angle inside test on an oriented cube.
%
%   The center of a closed outward cube is inside. A far point is outside.
%   zef_point_in_compartment (session argument) and zef_tetra_in_compartment
%   (same session, passed explicitly or present in the base workspace) must
%   agree. An explicit threshold override must be the value that is applied.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
            evalin('base', 'clear zef');
        end
    end

    methods (Test)
        function centerIsInsideAndFarPointIsOutside(testCase)
            [zef, points, triangles, queries] = tests.unit.CompartmentInclusionTest.cube();
            [inside, dist] = zef_point_in_compartment(zef, points, triangles, queries);
            testCase.verifyEqual(inside, [1; 3]);
            testCase.verifyEqual(numel(dist), 2);
            testCase.verifyGreaterThan(dist, 0);

            assignin('base', 'zef', zef);
            inside_tetra = zef_tetra_in_compartment(points, triangles, queries);
            testCase.verifyEqual(inside_tetra, inside);

            inside_direct = zef_tetra_in_compartment(points, triangles, queries, zef);
            testCase.verifyEqual(inside_direct, inside);
        end

        function thresholdOverrideRejectsEveryPoint(testCase)
            [zef, points, triangles, queries] = tests.unit.CompartmentInclusionTest.cube();
            [inside, ~] = zef_point_in_compartment(zef, points, triangles, queries, [], 2);
            testCase.verifyEmpty(inside);
            inside_tetra = zef_tetra_in_compartment(points, triangles, queries, zef, [], 2);
            testCase.verifyEmpty(inside_tetra);
        end
    end

    methods (Static)
        function [zef, points, triangles, queries] = cube()
            zef = tests.support.createSyntheticMeshZef();
            points = zef.c1_points;
            triangles = zef_orient_surface_outward(points, zef.c1_triangles);
            queries = [10 10 10; 100 0 0; 10 10 0.1; 1 1 1];
            zef.gpu_num = 1;
        end
    end
end
