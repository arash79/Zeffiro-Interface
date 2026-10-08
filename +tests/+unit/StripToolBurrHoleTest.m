classdef StripToolBurrHoleTest < matlab.unittest.TestCase
%STRIPTOOLBURRHOLETEST  Lead-centered burr holes: geometry, conductivity, UI.
%
%   The cylinder is the lead frame used by zef_create_strip. Membership is
%   the closed cylinder of the requested radius over the strip length, and
%   only tetrahedra labeled as the selected compartment. Conductivity is
%   written onto zef.sigma. Zero stays zero. The disabled path leaves sigma
%   unchanged.

    methods (TestClassSetup)
        function addPaths(~)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(fullfile(root, 'plugins', 'StripTool'));
            addpath(fullfile(root, 'src', 'gui', 'chrome'));
            addpath(fullfile(root, 'src', 'mesh'));
            addpath(fullfile(root, 'src', 'mesh', 'operators'));
            addpath(fullfile(root, 'src', 'app'));
        end
    end

    methods (Test)
        function leadFrameMatchesStripTransform(testCase)
            directions = {[0; 0; 1], [0; 0; -1], [1; 0; 0], [0; 1; 0], [1; 2; 3]};
            rolls = [0, 0.4, -0.7, 1.1, 0.2];
            for k = 1:numel(directions)
                strip = tests.unit.StripToolBurrHoleTest.builtLead( ...
                    1, [4; -2; 7], directions{k}, 12, rolls(k));
                local = [0, 0, 0; 0, 0, 12; 0.635, 0, 6; -0.2, 0.4, 1; 1, -1, 3];
                world = tests.unit.StripToolBurrHoleTest.forwardOf(strip, local);
                back = zef_strip_lead_frame(strip, world);
                testCase.verifyEqual(back, local, 'AbsTol', 1e-8);
                testCase.verifyEqual(world(1, :), strip.tip_point.', 'AbsTol', 1e-8);
                testCase.verifyEqual(norm(world(2, :) - world(1, :)), 12, 'AbsTol', 1e-8);
                axes_only = zef_strip_lead_axes(strip);
                testCase.verifyEqual(axes_only.orientation_axis{1}, strip.orientation_axis{1}, 'AbsTol', 1e-12);
                testCase.verifyEqual(axes_only.rotation_axis{1}, strip.rotation_axis{1}, 'AbsTol', 1e-12);
                testCase.verifyEqual(axes_only.rotation_angle{1}, strip.rotation_angle{1}, 'AbsTol', 1e-12);
                testCase.verifyEqual(axes_only.orientation_axis_normal{1}, ...
                    strip.orientation_axis_normal{1}, 'AbsTol', 1e-12);
            end
        end

        function previewSurfaceLiesOnTheAnalyticCylinder(testCase)
            strip = tests.unit.StripToolBurrHoleTest.builtLead(4, [1; 2; 3], [0; 1; 1], 15, 0.3);
            radius = 2.5;
            [~, pts] = zef_strip_burr_surface(strip, radius);
            local = zef_strip_lead_frame(strip, pts);
            radial = hypot(local(:, 1), local(:, 2));
            testCase.verifyLessThanOrEqual(max(radial), radius + 1e-6);
            testCase.verifyGreaterThan(max(radial), radius - 1e-3);
            testCase.verifyGreaterThanOrEqual(min(local(:, 3)), -1e-6);
            testCase.verifyLessThanOrEqual(max(local(:, 3)), 15 + 1e-6);
        end

        function disabledApplyDoesNotChangeConductivity(testCase)
            [zef, ~] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            sigma_before = zef.sigma;
            zef.s2_strip_cell{1}.burr_hole_on = 0;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1.2, 'conductivity', 4);
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            testCase.verifyEqual(zef.sigma, sigma_before);
            testCase.verifyFalse(report.mesh_updated);
            testCase.verifyEmpty(zef.strip_burr_state.index);
        end

        function oneCompartmentCylinderLeavesTheOtherUntouched(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            sigma_before = zef.sigma;
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1, 'conductivity', 5);
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            expected = tests.unit.StripToolBurrHoleTest.independentInside( ...
                zef, strip, 1, 1);
            testCase.verifyGreaterThan(numel(expected), 0);
            testCase.verifyEqual(sort(zef.strip_burr_state.index), sort(expected));
            testCase.verifyEqual(zef.sigma(expected, 1), repmat(5, numel(expected), 1));
            testCase.verifyEqual(zef.sigma(expected, 2), sigma_before(expected, 2));
            outside = true(size(zef.sigma, 1), 1);
            outside(expected) = false;
            testCase.verifyEqual(zef.sigma(outside, :), sigma_before(outside, :));
            testCase.verifyEqual(zef.sigma(zef.domain_labels == 2, :), ...
                sigma_before(zef.domain_labels == 2, :));
            testCase.verifyLessThanOrEqual(report.entries(1).max_radial_mm, 1 + 1e-8);
            testCase.verifyGreaterThan(report.entries(1).min_excluded_radial_mm, 1);
            originals = zef.strip_burr_state.original;
            [zef, ~] = zef_strip_apply_burr_holes(zef, 'reapply');
            testCase.verifyEqual(zef.sigma(expected, 1), repmat(5, numel(expected), 1));
            testCase.verifyEqual(zef.strip_burr_state.original, originals);
        end

        function compartmentsKeepIndependentRadiusAndConductivity(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(3);
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', {'left_tissue', 'right_tissue'}, ...
                'radius_mm', {0.6, 1.4}, ...
                'conductivity', {2, 0});
            lastwarn('');
            [zef, ~] = zef_strip_apply_burr_holes(zef, 'reapply');
            [~, warn_id] = lastwarn;
            testCase.verifyEqual(warn_id, 'zef:BurrHoleZeroConductivity');
            left = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 0.6);
            right = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 2, 1.4);
            testCase.verifyGreaterThan(numel(left), 0);
            testCase.verifyGreaterThan(numel(right), 0);
            testCase.verifyEqual(zef.sigma(left, 1), repmat(2, numel(left), 1));
            testCase.verifyEqual(zef.sigma(right, 1), zeros(numel(right), 1));
            between = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 1.4);
            annulus = setdiff(between, left);
            testCase.verifyGreaterThan(numel(annulus), 0);
            testCase.verifyEqual(zef.sigma(annulus, 1), repmat(0.2, numel(annulus), 1));
        end

        function tiltedLeadAndDisconnectedTissue(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.disconnectedModel();
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'split_tissue', 'radius_mm', 0.8, 'conductivity', 1.25);
            sigma_before = zef.sigma;
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            hit = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 0.8);
            testCase.verifyGreaterThan(numel(hit), 0);
            testCase.verifyEqual(sort(report.entries(1).n_assigned), numel(hit));
            testCase.verifyEqual(zef.sigma(hit, 1), repmat(1.25, numel(hit), 1));
            centroids = tests.unit.StripToolBurrHoleTest.centroids(zef.nodes, zef.tetra);
            far = centroids(:, 1) > 10;
            testCase.verifyEqual(zef.sigma(far, :), sigma_before(far, :));
            testCase.verifyGreaterThan(nnz(far), 0);
        end

        function shrinkRadiusRestoresTheAnnulus(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1.3, 'conductivity', 8);
            sigma_before = zef.sigma;
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            wide = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 1.3);
            zef.s2_strip_cell{1}.burr_holes.radius_mm = 0.45;
            zef.s2_strip_cell{1}.burr_holes.conductivity = 3;
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            narrow = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 0.45);
            restored = setdiff(wide, narrow);
            testCase.verifyGreaterThan(numel(narrow), 0);
            testCase.verifyGreaterThan(numel(restored), 0);
            testCase.verifyEqual(zef.sigma(narrow, 1), repmat(3, numel(narrow), 1));
            testCase.verifyEqual(zef.sigma(restored, :), sigma_before(restored, :));
        end

        function laterLeadWinsOverlapAndDeleteRestoresIt(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(2);
            first = zef.s2_strip_cell{1};
            second = first;
            second.strip_id = 2;
            first.burr_hole_on = 1;
            second.burr_hole_on = 1;
            first.burr_holes = struct('compartment_tag', 'left_tissue', ...
                'radius_mm', 1, 'conductivity', 2);
            second.burr_holes = struct('compartment_tag', 'left_tissue', ...
                'radius_mm', 1, 'conductivity', 6);
            zef.s2_strip_cell = {first, second};
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            hit = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 1);
            testCase.verifyEqual(zef.sigma(hit, 1), repmat(6, numel(hit), 1));
            zef.s2_strip_cell = {first};
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            testCase.verifyEqual(zef.sigma(hit, 1), repmat(2, numel(hit), 1));
        end

        function freshModeUsesRebuiltConductivity(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1, 'conductivity', 9);
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            hit = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 1);
            zef.sigma(:, 1) = 0.7;
            zef = zef_strip_apply_burr_holes(zef, 'fresh');
            outside = true(size(zef.sigma, 1), 1);
            outside(hit) = false;
            testCase.verifyEqual(zef.sigma(hit, 1), repmat(9, numel(hit), 1));
            testCase.verifyEqual(zef.sigma(outside, 1), repmat(0.7, nnz(outside), 1));
            zef.sigma(:, 1) = 0.7;
            zef.s2_strip_cell{1}.burr_hole_on = 0;
            zef = zef_strip_apply_burr_holes(zef, 'fresh');
            testCase.verifyEqual(zef.sigma(:, 1), repmat(0.7, size(zef.sigma, 1), 1));
        end

        function turningOptionOffRestoresOriginalValues(testCase)
            [zef, ~] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            sigma_before = zef.sigma;
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1, 'conductivity', 4);
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            zef.s2_strip_cell{1}.burr_hole_on = 0;
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            testCase.verifyEqual(zef.sigma, sigma_before);
            testCase.verifyGreaterThan(report.n_restored, 0);
            testCase.verifyEmpty(zef.strip_burr_state.index);
        end

        function unknownTagIsNotAppliedToAnotherCompartment(testCase)
            [zef, ~] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            sigma_before = zef.sigma;
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'not_a_tissue', 'radius_mm', 2, 'conductivity', 3);
            lastwarn('');
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            [~, warn_id] = lastwarn;
            testCase.verifyEqual(warn_id, 'zef:BurrHoleRejected');
            testCase.verifyEqual(zef.sigma, sigma_before);
            testCase.verifyTrue(contains(strjoin(report.messages, ' '), 'not_a_tissue'));
            testCase.verifyEmpty(zef.s2_strip_cell{1}.burr_holes);
        end

        function negativeConductivityIsRejectedNotClamped(testCase)
            [zef, ~] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            sigma_before = zef.sigma;
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1, 'conductivity', -0.5);
            lastwarn('');
            [zef, ~] = zef_strip_apply_burr_holes(zef, 'reapply');
            [msg, warn_id] = lastwarn;
            testCase.verifyEqual(warn_id, 'zef:BurrHoleRejected');
            testCase.verifyTrue(contains(msg, 'not replaced'));
            testCase.verifyEqual(zef.sigma, sigma_before);
        end

        function tinyRadiusDoesNotEnlargeItself(testCase)
            [zef, ~] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            sigma_before = zef.sigma;
            zef.mesh_resolution = 1;
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1e-4, 'conductivity', 3);
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            testCase.verifyEqual(zef.sigma, sigma_before);
            testCase.verifyTrue(contains(strjoin(report.messages, ' '), 'not increased'));
            testCase.verifyTrue(contains(strjoin(report.messages, ' '), 'Mesh resolution is 1 mm'));
        end

        function anisotropicReplacementIsIsotropicTensor(testCase)
            [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(1);
            n = size(zef.sigma, 1);
            zef.sigma(:, 3:8) = repmat([0.2, 0.3, 0.4, 0.01, 0.02, 0.03], n, 1);
            zef.s2_strip_cell{1}.burr_hole_on = 1;
            zef.s2_strip_cell{1}.burr_holes = struct( ...
                'compartment_tag', 'left_tissue', 'radius_mm', 1, 'conductivity', 1.5);
            host = zef.sigma;
            zef = zef_strip_apply_burr_holes(zef, 'reapply');
            hit = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 1);
            testCase.verifyEqual(zef.sigma(hit, 1), repmat(1.5, numel(hit), 1));
            testCase.verifyEqual(zef.sigma(hit, 3:5), repmat(1.5, numel(hit), 3));
            testCase.verifyEqual(zef.sigma(hit, 6:8), zeros(numel(hit), 3));
            testCase.verifyEqual(zef.sigma(hit, 2), host(hit, 2));
            outside = true(n, 1);
            outside(hit) = false;
            testCase.verifyEqual(zef.sigma(outside, :), host(outside, :));
        end

        function zeroConductivityAddsNothingToStiffness(testCase)
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            tetra = [1 2 3 4];
            volume = zef_tetra_volume(nodes, tetra, true);
            packed = @(s) [s; s; s; 0; 0; 0];
            A = zef_stiffness_matrix(nodes, tetra, volume, packed(0.25));
            A2 = zef_stiffness_matrix(nodes, tetra, volume, packed(1.5));
            A0 = zef_stiffness_matrix(nodes, tetra, volume, packed(0));
            testCase.verifyEqual(A2, A * (1.5 / 0.25), 'AbsTol', 1e-9);
            testCase.verifyEqual(nnz(A0), 0);
        end

        function everyLeadModelUsesTheSameCylinderRule(testCase)
            for model = 1:5
                [zef, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(model);
                zef.s2_strip_cell{1}.burr_hole_on = 1;
                zef.s2_strip_cell{1}.burr_holes = struct( ...
                    'compartment_tag', 'right_tissue', 'radius_mm', 0.9, 'conductivity', 0.11);
                zef = zef_strip_apply_burr_holes(zef, 'reapply');
                hit = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 2, 0.9);
                testCase.verifyGreaterThan(numel(hit), 0);
                testCase.verifyEqual(zef.sigma(hit, 1), repmat(0.11, numel(hit), 1));
                testCase.verifyEqual(zef.s2_strip_cell{1}.strip_model, model);
            end
        end

        function postprocessHookUsesFreshMode(testCase)
            text = fileread(which('zef_postprocess_fem_mesh'));
            testCase.verifyTrue(contains(text, 'zef_strip_apply_burr_holes'));
            testCase.verifyTrue(contains(text, 'zef_strip_burr_mode'));
            testCase.verifyTrue(contains(text, '''generate'''));
        end

        function interfaceStoresIndependentRowsPerLead(testCase)
            old_vis = get(0, 'DefaultFigureVisible');
            cleaner = onCleanup(@() set(0, 'DefaultFigureVisible', old_vis)); %#ok<NASGU>
            set(0, 'DefaultFigureVisible', 'off');
            zef = tests.unit.StripToolBurrHoleTest.guiSession();
            testCase.addTeardown(@() tests.unit.StripToolBurrHoleTest.closeWindow(zef));
            testCase.verifyEqual(zef.strip_tool.h_burr_hole_on.Value, 0);
            testCase.verifyEqual(zef.strip_tool.h_burr_hole_on.String, 'Create burr hole');

            zef.strip_tool.h_burr_hole_on.Value = 1;
            zef = zef_strip_tool_update(zef);
            tags = zef.strip_tool.h_burr_compartment.UserData;
            testCase.verifyEqual(tags, {'aa_custom', 'zz_bone', 'mm_csf'});

            zef.strip_tool.h_burr_compartment.Value = 2;
            zef.strip_tool.h_burr_radius.String = '2.25';
            zef.strip_tool.h_burr_conductivity.String = '0.0046';
            zef = zef_strip_tool_burr_set(zef);
            zef.strip_tool.h_burr_compartment.Value = 3;
            zef.strip_tool.h_burr_radius.String = '4';
            zef.strip_tool.h_burr_conductivity.String = '1.79';
            zef = zef_strip_tool_burr_set(zef);
            holes = zef.s2_strip_cell{1}.burr_holes;
            testCase.verifyEqual({holes.compartment_tag}, {'zz_bone', 'mm_csf'});
            testCase.verifyEqual([holes.radius_mm], [2.25, 4]);
            testCase.verifyEqual([holes.conductivity], [0.0046, 1.79]);
            testCase.verifyTrue(contains(zef.strip_tool.h_strip_list.UserData.Names{1}, 'Burr hole: On'));

            zef.strip_tool.h_burr_radius.String = '0';
            zef = zef_strip_tool_burr_set(zef);
            testCase.verifyEqual([zef.s2_strip_cell{1}.burr_holes.radius_mm], [2.25, 4]);
            testCase.verifyTrue(contains(zef.strip_tool.h_burr_status.String, 'greater than 0'));

            zef.strip_tool.h_burr_compartment.Value = 2;
            zef.strip_tool.h_burr_radius.String = '2.25';
            zef.strip_tool.h_burr_conductivity.String = '-1';
            zef = zef_strip_tool_burr_set(zef);
            testCase.verifyEqual(zef.s2_strip_cell{1}.burr_holes(1).conductivity, 0.0046);
            testCase.verifyTrue(contains(zef.strip_tool.h_burr_status.String, 'not replaced'));

            zef.strip_tool.h_burr_conductivity.String = '0';
            zef = zef_strip_tool_burr_set(zef);
            testCase.verifyEqual(zef.s2_strip_cell{1}.burr_holes(1).conductivity, 0);
            testCase.verifyTrue(contains(zef.strip_tool.h_burr_status.String, '0 S/m'));

            zef.strip_tool.current_strip = 2;
            zef = zef_strip_tool_init(zef);
            zef = zef_strip_tool_update(zef);
            testCase.verifyEqual(zef.strip_tool.h_burr_hole_on.Value, 0);
            testCase.verifyEqual(zef.strip_tool.h_burr_list.UserData, {''});
            zef.strip_tool.h_burr_hole_on.Value = 1;
            zef = zef_strip_tool_update(zef);
            zef.strip_tool.h_burr_compartment.Value = 1;
            zef.strip_tool.h_burr_radius.String = '6';
            zef.strip_tool.h_burr_conductivity.String = '0.33';
            zef = zef_strip_tool_burr_set(zef);
            testCase.verifyEqual(zef.s2_strip_cell{2}.burr_holes.compartment_tag, 'aa_custom');
            testCase.verifyEqual(numel(zef.s2_strip_cell{1}.burr_holes), 2);

            zef.strip_tool.current_strip = 1;
            zef = zef_strip_tool_init(zef);
            zef = zef_strip_tool_update(zef);
            testCase.verifyEqual(zef.strip_tool.h_burr_hole_on.Value, 1);
            zef.strip_tool.h_burr_list.Value = 2;
            zef = zef_strip_tool_burr_remove(zef);
            testCase.verifyEqual({zef.s2_strip_cell{1}.burr_holes.compartment_tag}, {'zz_bone'});

            zef.compartment_tags = {'aa_custom', 'mm_csf'};
            zef = zef_strip_tool_update(zef);
            testCase.verifyEmpty(zef.s2_strip_cell{1}.burr_holes);
            testCase.verifyTrue(contains(zef.strip_tool.h_burr_status.String, 'zz_bone'));
        end

        function applyButtonWritesOnlyTheSelectedDomain(testCase)
            old_vis = get(0, 'DefaultFigureVisible');
            cleaner = onCleanup(@() set(0, 'DefaultFigureVisible', old_vis)); %#ok<NASGU>
            set(0, 'DefaultFigureVisible', 'off');
            [mesh, strip] = tests.unit.StripToolBurrHoleTest.twoDomainModel(5);
            zef = tests.unit.StripToolBurrHoleTest.guiSession();
            testCase.addTeardown(@() tests.unit.StripToolBurrHoleTest.closeWindow(zef));
            zef.nodes = mesh.nodes;
            zef.tetra = mesh.tetra;
            zef.sigma = mesh.sigma;
            zef.domain_labels = mesh.domain_labels;
            zef.mesh_resolution = 1;
            zef.s2_strip_cell{1} = strip;
            zef.s2_strip_cell{1}.burr_hole_on = 0;
            zef.s2_strip_cell{1}.strip_status = 'Tentative';
            zef.strip_tool.current_strip = 1;
            zef = zef_strip_tool_init(zef);
            zef.strip_tool.h_burr_hole_on.Value = 1;
            zef = zef_strip_tool_update(zef);
            zef.compartment_tags = mesh.compartment_tags;
            zef.left_tissue_name = 'Left tissue';
            zef.left_tissue_on = 1;
            zef.left_tissue_sigma = 0.2;
            zef.right_tissue_name = 'Right tissue';
            zef.right_tissue_on = 1;
            zef.right_tissue_sigma = 0.4;
            zef = zef_strip_tool_update(zef);
            left = find(strcmp(zef.strip_tool.h_burr_compartment.UserData, 'left_tissue'));
            zef.strip_tool.h_burr_compartment.Value = left;
            zef.strip_tool.h_burr_radius.String = '1';
            zef.strip_tool.h_burr_conductivity.String = '7';
            sigma_before = zef.sigma;
            zef = zef_strip_tool_burr_set(zef);
            zef = zef_strip_tool_burr_apply(zef);
            hit = tests.unit.StripToolBurrHoleTest.independentInside(zef, strip, 1, 1);
            testCase.verifyGreaterThan(numel(hit), 0);
            testCase.verifyEqual(zef.sigma(hit, 1), repmat(7, numel(hit), 1));
            outside = true(size(sigma_before, 1), 1);
            outside(hit) = false;
            testCase.verifyEqual(zef.sigma(outside, :), sigma_before(outside, :));
            testCase.verifyTrue(contains(zef.strip_tool.h_burr_status.String, '7'));
        end
    end

    methods (Static, Access = private)
        function strip = baseLead(model, tip, direction, len, angle)
            strip = struct();
            strip.strip_model = model;
            strip.orientation_axis = {direction(:), direction(:)};
            strip.tip_point = tip(:);
            strip.strip_angle = angle;
            strip.strip_length = len;
            strip.encapsulation_length = len;
            strip.encapsulation_thickness = 0.5;
            strip.encapsulation_on = 0;
            strip.encapsulation_shift = [0; 0; 0];
            strip.strip_n_sectors = 12;
            strip.strip_id = 1;
            strip.strip_tag = 'lead';
            strip.strip_status = 'Tentative';
            strip.burr_hole_on = 0;
            strip.burr_holes = zef_strip_burr_normalize([]);
        end

        function strip = builtLead(model, tip, direction, len, angle)
            strip = zef_create_strip(tests.unit.StripToolBurrHoleTest.baseLead( ...
                model, tip, direction, len, angle));
        end

        function world = forwardOf(strip, local_points)
            aux = strip;
            aux.encapsulation_on = 0;
            aux.points = {local_points};
            world = zef_strip_coordinate_transform(aux, 'forward');
            world = world{1};
        end

        function [nodes, tetra] = lattice(origin, span, step)
            x = origin(1):step:(origin(1) + span(1));
            y = origin(2):step:(origin(2) + span(2));
            z = origin(3):step:(origin(3) + span(3));
            [X, Y, Z] = ndgrid(x, y, z);
            tri = delaunayTriangulation([X(:), Y(:), Z(:)]);
            nodes = tri.Points;
            tetra = tri.ConnectivityList;
        end

        function [zef, strip] = twoDomainModel(model)
            [nodes, tetra] = tests.unit.StripToolBurrHoleTest.lattice([-2, -2, -2], [4, 4, 4], 0.55);
            c = tests.unit.StripToolBurrHoleTest.centroids(nodes, tetra);
            domain = ones(size(tetra, 1), 1);
            domain(c(:, 1) >= 0) = 2;
            sigma = [0.2 * ones(size(domain)), domain];
            sigma(domain == 2, 1) = 0.4;
            strip = tests.unit.StripToolBurrHoleTest.baseLead( ...
                model, [-2; 0; 0], [1; 0; 0], 4, 0);
            zef = tests.unit.StripToolBurrHoleTest.session(nodes, tetra, domain, sigma, strip);
            zef.compartment_tags = {'left_tissue', 'right_tissue'};
            zef.left_tissue_name = 'Left tissue';
            zef.left_tissue_on = 1;
            zef.left_tissue_sigma = 0.2;
            zef.right_tissue_name = 'Right tissue';
            zef.right_tissue_on = 1;
            zef.right_tissue_sigma = 0.4;
        end

        function [zef, strip] = disconnectedModel()
            [n1, t1] = tests.unit.StripToolBurrHoleTest.lattice([-1.5, -1.2, -1.2], [3, 2.4, 2.4], 0.6);
            [n2, t2] = tests.unit.StripToolBurrHoleTest.lattice([18, -1.2, -1.2], [3, 2.4, 2.4], 0.6);
            nodes = [n1; n2];
            tetra = [t1; t2 + size(n1, 1)];
            domain = ones(size(tetra, 1), 1);
            sigma = [0.55 * ones(size(domain)), domain];
            strip = tests.unit.StripToolBurrHoleTest.baseLead( ...
                4, [-1.5; 0; 0], [1; 1; 0.5], 6, 0.2);
            zef = tests.unit.StripToolBurrHoleTest.session(nodes, tetra, domain, sigma, strip);
            zef.compartment_tags = {'split_tissue'};
            zef.split_tissue_name = 'Split tissue';
            zef.split_tissue_on = 1;
            zef.split_tissue_sigma = 0.55;
        end

        function zef = session(nodes, tetra, domain, sigma, strip)
            zef = struct();
            zef.nodes = nodes;
            zef.tetra = tetra;
            zef.domain_labels = domain;
            zef.sigma = sigma;
            zef.current_sensors = 's2';
            zef.s2_strip_cell = {strip};
            zef.mesh_resolution = 0.55;
        end

        function c = centroids(nodes, tetra)
            c = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) ...
                + nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) * 0.25;
        end

        function index = independentInside(zef, strip, domain_id, radius_mm)
            built = zef_create_strip(strip);
            c = tests.unit.StripToolBurrHoleTest.centroids(zef.nodes, zef.tetra);
            local = zef_strip_lead_frame(built, c);
            radial = hypot(local(:, 1), local(:, 2));
            axial = local(:, 3);
            tol = 1e-8;
            index = find(zef.domain_labels == domain_id ...
                & radial <= radius_mm + tol ...
                & axial >= -tol ...
                & axial <= built.strip_length + tol);
        end

        function zef = guiSession()
            zef = struct('strip_tool', struct());
            zef = zef_strip_tool_window(zef);
            zef.current_sensors = 's2';
            zef.strip_tool.current_strip = 1;
            zef.strip_tool.strip_current_id = 2;
            zef.compartment_tags = {'aa_custom', 'zz_bone', 'mm_csf'};
            zef.aa_custom_name = 'Custom mantle';
            zef.aa_custom_on = 1;
            zef.aa_custom_sigma = 0.33;
            zef.zz_bone_name = 'Compact shell';
            zef.zz_bone_on = 1;
            zef.zz_bone_sigma = 0.0064;
            zef.mm_csf_name = 'Fluid space';
            zef.mm_csf_on = 1;
            zef.mm_csf_sigma = 1.79;
            lead = tests.unit.StripToolBurrHoleTest.baseLead(4, [0; 0; 0], [0; 0; 1], 40, 0);
            other = lead;
            other.strip_id = 2;
            other.strip_model = 5;
            other.strip_tag = 'second';
            zef.s2_strip_cell = {lead, other};
            zef = zef_strip_tool_init(zef);
            zef = zef_strip_tool_update(zef);
        end

        function closeWindow(zef)
            if isstruct(zef) && isfield(zef, 'strip_tool') ...
                    && isfield(zef.strip_tool, 'h_window') ...
                    && isgraphics(zef.strip_tool.h_window)
                delete(zef.strip_tool.h_window);
            end
        end
    end
end
