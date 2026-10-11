classdef FeatureAwareMeshTest < matlab.unittest.TestCase
%FEATUREAWAREMESHTEST  Orientation, compartment labels, and local spacing.
%
%   Solid-angle labeling keeps a node only when the summed projected area
%   is greater than meshing_threshold. That sum is positive inside a closed
%   surface when the triangles wind outward. These tests use the production
%   mesh functions on small geometries. Lattice spacing is zef.mesh_resolution;
%   a 5-tet cube also has face diagonals of that spacing times sqrt(2).
%   Stored tetrahedron orientation follows zef_mesh_refinement, which swaps
%   any positive volume to negative, so a valid tet has nonzero volume and
%   the signs that the refinement pass actually wrote are not required to
%   be positive.

    methods (TestClassSetup)
        function addPaths(~)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(root);
            addpath(genpath(fullfile(root, 'src')));
            addpath(fullfile(root, 'plugins', 'StripTool'));
        end
    end

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function outwardWindingHasPositiveVolume(testCase)
            [points, triangles] = tests.unit.FeatureAwareMeshTest.sphere_surface([0 0 0], 4, 10, 8);
            triangles = zef_orient_surface_outward(points, triangles);
            testCase.verifyGreaterThan(tests.unit.FeatureAwareMeshTest.signed_volume(points, triangles), 0);
            reversed = triangles(:, [1 3 2]);
            testCase.verifyLessThan(tests.unit.FeatureAwareMeshTest.signed_volume(points, reversed), 0);
            restored = zef_orient_surface_outward(points, reversed);
            testCase.verifyGreaterThan(tests.unit.FeatureAwareMeshTest.signed_volume(points, restored), 0);
            testCase.verifyGreaterThan(tests.unit.FeatureAwareMeshTest.solid_angle(points, restored, [0 0 0]), 0.25);
        end

        function atlasExportSwapIsOutwardOnlyAfterOrient(testCase)
            atlas.Cube = zeros(6, 6, 6);
            atlas.Cube(2:5, 2:5, 2:5) = 1;
            atlas.Labels = {1, 'ball', [200 200 200]};
            atlas.Comment = 'toy';
            atlas.SkipZefWaitbar = true;
            zef = struct('inflate_strength', 0.3, 'inflate_n_iterations', 0, ...
                'use_gpu', 0, 'gpu_count', 0, 'use_gpu_graphic', 0);
            surfaces = utilities.brainstorm2zef.zef_bst_get_atlas_surfaces( ...
                zef, atlas, 0, cell(0), '', 0);
            points = surfaces(1).Points;
            triangles = surfaces(1).Triangles;
            % Same reflection sn2zef applies before multiplying by vox2ras.
            reflected = [points(:, 2), points(:, 1), points(:, 3)];
            blind_flip = triangles(:, [1 3 2]);
            testCase.verifyLessThan(tests.unit.FeatureAwareMeshTest.signed_volume(reflected, blind_flip), 0);
            oriented = zef_orient_surface_outward(reflected, triangles);
            testCase.verifyGreaterThan(tests.unit.FeatureAwareMeshTest.signed_volume(reflected, oriented), 0);
            center = mean(reflected, 1);
            testCase.verifyGreaterThan(tests.unit.FeatureAwareMeshTest.solid_angle(reflected, oriented, center), 0.25);
            exporter = fileread(which('utilities.sn2zef.export_segmentation_meshes'));
            testCase.verifyTrue(contains(exporter, 'zef_orient_surface_outward'));
            testCase.verifyFalse(contains(exporter, 'tris(:, [1 3 2])'));
        end

        function freesurferAsciiBundledSurfacesAreAlreadyOutward(testCase)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            mesh_file = fullfile(root, 'data', 'segmentations', ...
                'multicompartment_head_project', 'lh.thalamus.asc');
            testCase.assumeTrue(isfile(mesh_file));
            [nodes, faces] = utilities.fs2zef.readers.read_ascii_segmentation_file(string(mesh_file));
            points = double(nodes');
            triangles = double(faces') + 1;
            volume = tests.unit.FeatureAwareMeshTest.signed_volume(points, triangles);
            testCase.verifyGreaterThan(volume, 0);
            oriented = zef_orient_surface_outward(points, triangles);
            testCase.verifyEqual(oriented, triangles);
        end

        function singleClosedSurfaceKeepsInterior(testCase)
            [sphere_points, sphere_triangles] = tests.unit.FeatureAwareMeshTest.sphere_surface([0 0 0], 6, 12, 8);
            [cube_points, cube_triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([-8 -8 -8], [16 16 16]);
            zef = tests.unit.FeatureAwareMeshTest.session(1.5, true);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_in', 'Sphere', sphere_points, sphere_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_out', 'Cube', cube_points, cube_triangles);
            zef.compartment_tags = {'c_in', 'c_out'};
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.FeatureAwareMeshTest.assert_nondegenerate(testCase, zef);
            interior = tests.unit.FeatureAwareMeshTest.nearest_label(zef, [0 0 0]);
            exterior = tests.unit.FeatureAwareMeshTest.nearest_label(zef, [7 7 7]);
            testCase.verifyEqual(interior, 1);
            testCase.verifyEqual(exterior, 2);
            analytic = 4 / 3 * pi * 6 ^ 3;
            mesh_volume = tests.unit.FeatureAwareMeshTest.label_volume(zef, 1);
            % One lattice cell of erosion on an approach-1 (8-corner) label.
            testCase.verifyGreaterThan(mesh_volume, 0.35 * analytic);
            testCase.verifyLessThan(mesh_volume, analytic);
        end

        function reversedSurfaceIsCorrectedBeforeLabeling(testCase)
            [sphere_points, sphere_triangles] = tests.unit.FeatureAwareMeshTest.sphere_surface([0 0 0], 6, 12, 8);
            sphere_triangles = zef_orient_surface_outward(sphere_points, sphere_triangles);
            [cube_points, cube_triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([-8 -8 -8], [16 16 16]);
            outward = tests.unit.FeatureAwareMeshTest.mesh_pair(1.5, ...
                sphere_points, sphere_triangles, cube_points, cube_triangles);
            inward = tests.unit.FeatureAwareMeshTest.mesh_pair(1.5, ...
                sphere_points, sphere_triangles(:, [1 3 2]), cube_points, cube_triangles);
            testCase.verifyEqual(nnz(outward.domain_labels == 1), nnz(inward.domain_labels == 1));
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(inward, [0 0 0]), 1);
        end

        function nestedCompartmentsAllReceiveVolume(testCase)
            radii = [4, 7, 10];
            zef = tests.unit.FeatureAwareMeshTest.session(2, false);
            tags = {'c_in', 'c_mid', 'c_out'};
            for index = 1:3
                [points, triangles] = tests.unit.FeatureAwareMeshTest.sphere_surface([0 0 0], radii(index), 12, 8);
                zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, tags{index}, tags{index}, points, triangles);
            end
            zef.compartment_tags = tags;
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.FeatureAwareMeshTest.assert_nondegenerate(testCase, zef);
            for index = 1:3
                testCase.verifyGreaterThan(nnz(zef.domain_labels == index), 0);
            end
            inner_volume = tests.unit.FeatureAwareMeshTest.label_volume(zef, 1);
            analytic = 4 / 3 * pi * radii(1) ^ 3;
            testCase.verifyGreaterThan(inner_volume, 0.2 * analytic);
            testCase.verifyLessThan(inner_volume, analytic);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(zef, [0 0 0]), 1);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(zef, [5.5 0 0]), 2);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(zef, [8.5 0 0]), 3);
        end

        function embeddedLeadDoesNotEraseSurroundingCompartment(testCase)
            [brain_points, brain_triangles] = tests.unit.FeatureAwareMeshTest.sphere_surface([0 0 3], 3.2, 12, 8);
            [box_points, box_triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([-4 -4 0], [8 8 6]);
            [shaft_points, shaft_triangles] = tests.unit.FeatureAwareMeshTest.cylinder_surface(0.34, 1, 5, 16);
            without = tests.unit.FeatureAwareMeshTest.session(0.5, true);
            without = tests.unit.FeatureAwareMeshTest.add_compartment(without, 'c_brain', 'Brain', brain_points, brain_triangles);
            without = tests.unit.FeatureAwareMeshTest.add_compartment(without, 'c_box', 'Box', box_points, box_triangles);
            without.compartment_tags = {'c_brain', 'c_box'};
            without = zef_process_meshes(without);
            without = zef_create_fem_mesh(without);
            brain_without = nnz(without.domain_labels == 1);

            with_lead = tests.unit.FeatureAwareMeshTest.session(0.5, true);
            with_lead = tests.unit.FeatureAwareMeshTest.add_compartment(with_lead, 'c_shaft', 'Shaft', shaft_points, shaft_triangles);
            with_lead = tests.unit.FeatureAwareMeshTest.add_compartment(with_lead, 'c_brain', 'Brain', brain_points, brain_triangles);
            with_lead = tests.unit.FeatureAwareMeshTest.add_compartment(with_lead, 'c_box', 'Box', box_points, box_triangles);
            with_lead.compartment_tags = {'c_shaft', 'c_brain', 'c_box'};
            with_lead = zef_process_meshes(with_lead);
            with_lead = zef_create_fem_mesh(with_lead);
            tests.unit.FeatureAwareMeshTest.assert_nondegenerate(testCase, with_lead);
            testCase.verifyGreaterThan(brain_without, 0);
            testCase.verifyGreaterThan(nnz(with_lead.domain_labels == 1), 0);
            testCase.verifyGreaterThan(nnz(with_lead.domain_labels == 2), 0.5 * brain_without);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(with_lead, [0 0 3]), 1);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(with_lead, [1.5 0 3]), 2);
        end

        function thinShaftAndContactStayDistinct(testCase)
            [contact_points, contact_triangles] = tests.unit.FeatureAwareMeshTest.sphere_surface([0 0 3], 0.16, 8, 6);
            [shaft_points, shaft_triangles] = tests.unit.FeatureAwareMeshTest.cylinder_surface(0.45, 1, 5, 16);
            [box_points, box_triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([-2 -2 0], [4 4 6]);
            zef = tests.unit.FeatureAwareMeshTest.session(0.5, true);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_contact', 'Contact', contact_points, contact_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_shaft', 'Shaft', shaft_points, shaft_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_box', 'Tissue', box_points, box_triangles);
            zef.compartment_tags = {'c_contact', 'c_shaft', 'c_box'};
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.FeatureAwareMeshTest.assert_nondegenerate(testCase, zef);
            testCase.verifyGreaterThan(nnz(zef.domain_labels == 1), 0);
            testCase.verifyGreaterThan(nnz(zef.domain_labels == 2), 0);
            contact_centroids = tests.unit.FeatureAwareMeshTest.centroids_of(zef, 1);
            contact_radius = sqrt(sum((contact_centroids - [0 0 3]) .^ 2, 2));
            testCase.verifyLessThan(max(contact_radius), 0.16 + 0.5);
            shaft_centroids = tests.unit.FeatureAwareMeshTest.centroids_of(zef, 2);
            shaft_radius = sqrt(shaft_centroids(:, 1) .^ 2 + shaft_centroids(:, 2) .^ 2);
            testCase.verifyLessThan(max(shaft_radius), 0.45 + 0.5);
        end

        function encapsulationWallIsSeparateFromShaftAndTissue(testCase)
            [shaft_points, shaft_triangles] = tests.unit.FeatureAwareMeshTest.cylinder_surface(0.30, 1, 5, 16);
            [wall_points, wall_triangles] = tests.unit.FeatureAwareMeshTest.cylinder_surface(0.70, 0.7, 5.3, 16);
            [box_points, box_triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([-2.5 -2.5 0], [5 5 6]);
            zef = tests.unit.FeatureAwareMeshTest.session(0.5, true);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_shaft', 'Shaft', shaft_points, shaft_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_wall', 'Encapsulation', wall_points, wall_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_box', 'Tissue', box_points, box_triangles);
            zef.compartment_tags = {'c_shaft', 'c_wall', 'c_box'};
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            tests.unit.FeatureAwareMeshTest.assert_nondegenerate(testCase, zef);
            testCase.verifyGreaterThan(nnz(zef.domain_labels == 1), 0);
            testCase.verifyGreaterThan(nnz(zef.domain_labels == 2), 0);
            testCase.verifyGreaterThan(nnz(zef.domain_labels == 3), 0);
            length_mm = 4;
            shaft_analytic = pi * 0.30 ^ 2 * length_mm;
            wall_analytic = pi * (0.70 ^ 2 - 0.30 ^ 2) * length_mm;
            shaft_volume = tests.unit.FeatureAwareMeshTest.label_volume(zef, 1);
            wall_volume = tests.unit.FeatureAwareMeshTest.label_volume(zef, 2);
            testCase.verifyGreaterThan(shaft_volume, 0.15 * shaft_analytic);
            testCase.verifyLessThan(shaft_volume, 2.5 * shaft_analytic);
            testCase.verifyGreaterThan(wall_volume, 0.15 * wall_analytic);
            testCase.verifyLessThan(wall_volume, 2.5 * wall_analytic);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(zef, [0 0 3]), 1);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(zef, [0.5 0 3]), 2);
            testCase.verifyEqual(tests.unit.FeatureAwareMeshTest.nearest_label(zef, [1.5 0 3]), 3);
        end

        function requestedSpacingIsTheLatticeStep(testCase)
            [points, triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([0 0 0], [4 4 4]);
            zef = tests.unit.FeatureAwareMeshTest.session(0.5, false);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c1', 'Cube', points, triangles);
            zef.compartment_tags = {'c1'};
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            edges = tests.unit.FeatureAwareMeshTest.edge_lengths(zef);
            testCase.verifyEqual(zef.mesh_resolution, 0.5);
            testCase.verifyEqual(zef.feature_refinement_report.refined, false);
            % Mode-1 cubes contribute edges h and h*sqrt(2), not the space diagonal.
            short_edges = edges(edges < 0.6);
            long_edges = edges(edges >= 0.6);
            testCase.verifyLessThan(max(abs(short_edges - 0.5)), 1e-8);
            testCase.verifyLessThan(max(abs(long_edges - 0.5 * sqrt(2))), 1e-8);
        end

        function smallFeatureIsRefinedAndDistantLatticeStaysCoarse(testCase)
            [shaft_points, shaft_triangles] = tests.unit.FeatureAwareMeshTest.cylinder_surface(0.34, 1, 5, 16);
            [box_points, box_triangles] = tests.unit.FeatureAwareMeshTest.cube_surface([-3 -3 0], [6 6 6]);
            zef = tests.unit.FeatureAwareMeshTest.session(0.5, true);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_shaft', 'Shaft', shaft_points, shaft_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_box', 'Tissue', box_points, box_triangles);
            zef.compartment_tags = {'c_shaft', 'c_box'};
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            testCase.verifyGreaterThan(zef.feature_refinement_report.passes, 0);
            testCase.verifyLessThan(zef.feature_refinement_report.min_target, 0.5);
            centroids = tests.unit.FeatureAwareMeshTest.all_centroids(zef);
            longest = tests.unit.FeatureAwareMeshTest.longest_edges(zef);
            near_axis = centroids(:, 1) .^ 2 + centroids(:, 2) .^ 2 < 0.2 ^ 2 ...
                & centroids(:, 3) > 2 & centroids(:, 3) < 4;
            far_corner = centroids(:, 1) > 2 & centroids(:, 2) > 2;
            testCase.verifyGreaterThan(nnz(near_axis), 0);
            testCase.verifyGreaterThan(nnz(far_corner), 0);
            testCase.verifyLessThan(median(longest(near_axis)), 0.5);
            testCase.verifyGreaterThan(median(longest(far_corner)), 0.45);
            testCase.verifyLessThan(median(longest(far_corner)), 0.8);
        end

        function uniformCubeMeshStillFills(testCase)
            zef = tests.support.createSyntheticMeshZef();
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            testCase.verifyGreaterThan(size(zef.nodes, 1), 8);
            testCase.verifyGreaterThan(size(zef.tetra, 1), 1);
            testCase.verifyTrue(all(zef.domain_labels == 1));
            testCase.verifyEqual(zef.feature_refinement_report.refined, false);
        end

        function discShaftSurfaceIsClosedAndOutward(testCase)
            strip.strip_model = 5;
            strip.strip_radius = 0.337;
            strip.strip_length = 4;
            strip.strip_n_sectors = 10;
            [triangles, points] = zef_strip_disc_surface(strip);
            testCase.verifyGreaterThan(tests.unit.FeatureAwareMeshTest.signed_volume(points, triangles), 0);
            oriented = zef_orient_surface_outward(points, triangles);
            testCase.verifyEqual(oriented, triangles);
        end
    end

    methods (Static, Access = private)
        function zef = session(mesh_resolution, refine_features)
            zef = tests.support.createSyntheticMeshZef();
            zef.mesh_resolution = mesh_resolution;
            zef.feature_refinement_on = refine_features;
            zef.distance_smoothing_on = 0;
            zef.gpu_num = 0;
            zef.compartment_tags = {};
        end

        function zef = add_compartment(zef, tag, name, points, triangles)
            zef.([tag '_on']) = 1;
            zef.([tag '_name']) = name;
            zef.([tag '_sigma']) = 1;
            zef.([tag '_priority']) = 1;
            zef.([tag '_sources']) = 0;
            zef.([tag '_scaling']) = 1;
            zef.([tag '_x_correction']) = 0;
            zef.([tag '_y_correction']) = 0;
            zef.([tag '_z_correction']) = 0;
            zef.([tag '_xy_rotation']) = 0;
            zef.([tag '_yz_rotation']) = 0;
            zef.([tag '_zx_rotation']) = 0;
            zef.([tag '_affine_transform']) = {eye(4)};
            zef.([tag '_points_inf']) = [];
            zef.([tag '_submesh_ind']) = size(triangles, 1);
            zef.([tag '_points']) = points;
            zef.([tag '_triangles']) = triangles;
            zef.([tag '_labeling_priority']) = 0;
        end

        function zef = mesh_pair(mesh_resolution, inner_points, inner_triangles, outer_points, outer_triangles)
            zef = tests.unit.FeatureAwareMeshTest.session(mesh_resolution, false);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_in', 'Inner', inner_points, inner_triangles);
            zef = tests.unit.FeatureAwareMeshTest.add_compartment(zef, 'c_out', 'Outer', outer_points, outer_triangles);
            zef.compartment_tags = {'c_in', 'c_out'};
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
        end

        function assert_nondegenerate(testCase, zef)
            volumes = tests.unit.FeatureAwareMeshTest.tet_volumes(zef);
            scale = zef.mesh_resolution ^ 3;
            testCase.verifyGreaterThan(min(abs(volumes)), 1e-8 * scale);
            testCase.verifyEqual(nnz(~isfinite(volumes)), 0);
        end

        function label = nearest_label(zef, point)
            centroids = tests.unit.FeatureAwareMeshTest.all_centroids(zef);
            [~, index] = min(sum((centroids - point) .^ 2, 2));
            label = zef.domain_labels(index);
        end

        function centroids = centroids_of(zef, label)
            selected = zef.tetra(zef.domain_labels == label, :);
            centroids = (zef.nodes(selected(:, 1), :) + zef.nodes(selected(:, 2), :) + ...
                zef.nodes(selected(:, 3), :) + zef.nodes(selected(:, 4), :)) / 4;
        end

        function centroids = all_centroids(zef)
            tetra = zef.tetra;
            centroids = (zef.nodes(tetra(:, 1), :) + zef.nodes(tetra(:, 2), :) + ...
                zef.nodes(tetra(:, 3), :) + zef.nodes(tetra(:, 4), :)) / 4;
        end

        function volume = label_volume(zef, label)
            selected = zef.domain_labels == label;
            volumes = tests.unit.FeatureAwareMeshTest.tet_volumes(zef);
            volume = sum(abs(volumes(selected)));
        end

        function volumes = tet_volumes(zef)
            tetra = zef.tetra;
            v1 = zef.nodes(tetra(:, 1), :);
            v2 = zef.nodes(tetra(:, 2), :);
            v3 = zef.nodes(tetra(:, 3), :);
            v4 = zef.nodes(tetra(:, 4), :);
            volumes = dot(v1 - v4, cross(v2 - v4, v3 - v4, 2), 2) / 6;
        end

        function lengths = edge_lengths(zef)
            tetra = zef.tetra;
            pairs = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
            lengths = zeros(size(tetra, 1) * size(pairs, 1), 1);
            for edge = 1:size(pairs, 1)
                difference = zef.nodes(tetra(:, pairs(edge, 1)), :) - zef.nodes(tetra(:, pairs(edge, 2)), :);
                lengths((edge - 1) * size(tetra, 1) + (1:size(tetra, 1))) = vecnorm(difference, 2, 2);
            end
        end

        function longest = longest_edges(zef)
            tetra = zef.tetra;
            pairs = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
            longest = zeros(size(tetra, 1), 1);
            for edge = 1:size(pairs, 1)
                difference = zef.nodes(tetra(:, pairs(edge, 1)), :) - zef.nodes(tetra(:, pairs(edge, 2)), :);
                longest = max(longest, vecnorm(difference, 2, 2));
            end
        end

        function volume = signed_volume(points, triangles)
            v1 = points(triangles(:, 1), :);
            v2 = points(triangles(:, 2), :);
            v3 = points(triangles(:, 3), :);
            volume = sum(dot(v1, cross(v2 - v1, v3 - v1, 2), 2)) / 6;
        end

        function value = solid_angle(points, triangles, query)
            v1 = points(triangles(:, 1), :);
            v2 = points(triangles(:, 2), :);
            v3 = points(triangles(:, 3), :);
            centroid = (v1 + v2 + v3) / 3;
            area = cross(v2 - v1, v3 - v1, 2) / 2;
            offset = centroid - query(:)';
            distance = max(vecnorm(offset, 2, 2), 1e-15);
            value = sum(sum(offset .* area, 2) ./ distance .^ 3) / (4 * pi);
        end

        function [points, triangles] = cube_surface(origin, size_xyz)
            unit_points = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            triangles = [1 4 3; 1 3 2; 5 6 7; 5 7 8; 1 2 6; 1 6 5; ...
                4 8 7; 4 7 3; 1 5 8; 1 8 4; 2 3 7; 2 7 6];
            points = unit_points .* size_xyz(:).' + origin(:).';
        end

        function [points, triangles] = cylinder_surface(radius, z0, z1, n_sides)
            theta = linspace(0, 2 * pi, n_sides + 1)';
            theta(end) = [];
            lower = [radius * cos(theta), radius * sin(theta), repmat(z0, n_sides, 1)];
            upper = [radius * cos(theta), radius * sin(theta), repmat(z1, n_sides, 1)];
            points = [lower; upper; 0 0 z0; 0 0 z1];
            triangles = zeros(4 * n_sides, 3);
            for side = 1:n_sides
                nxt = mod(side, n_sides) + 1;
                triangles(side, :) = [side, side + n_sides, nxt];
                triangles(n_sides + side, :) = [nxt, side + n_sides, nxt + n_sides];
                triangles(2 * n_sides + side, :) = [2 * n_sides + 1, nxt, side];
                triangles(3 * n_sides + side, :) = [2 * n_sides + 2, side + n_sides, nxt + n_sides];
            end
            triangles = zef_orient_surface_outward(points, triangles);
        end

        function [points, triangles] = sphere_surface(center, radius, n_u, n_v)
            theta = linspace(0, 2 * pi, n_u + 1);
            theta(end) = [];
            phi = linspace(0, pi, n_v + 1);
            rings = cell(numel(phi), 1);
            for row = 1:numel(phi)
                if row == 1
                    rings{row} = [0 0 radius];
                elseif row == numel(phi)
                    rings{row} = [0 0 -radius];
                else
                    rings{row} = [radius * sin(phi(row)) * cos(theta(:)), ...
                        radius * sin(phi(row)) * sin(theta(:)), ...
                        radius * cos(phi(row)) * ones(numel(theta), 1)];
                end
            end
            points = vertcat(rings{:});
            triangles = zeros(0, 3);
            north = 1;
            first_ring = 2;
            for side = 1:n_u
                nxt = mod(side, n_u) + 1;
                triangles(end + 1, :) = [north, first_ring + side - 1, first_ring + nxt - 1]; %#ok<AGROW>
            end
            for row = 2:numel(phi) - 2
                row_start = 2 + (row - 2) * n_u;
                next_start = row_start + n_u;
                for side = 1:n_u
                    nxt = mod(side, n_u) + 1;
                    a = row_start + side - 1;
                    b = row_start + nxt - 1;
                    c = next_start + side - 1;
                    d = next_start + nxt - 1;
                    triangles(end + 1, :) = [a, c, b]; %#ok<AGROW>
                    triangles(end + 1, :) = [b, c, d]; %#ok<AGROW>
                end
            end
            south = size(points, 1);
            last_start = south - n_u;
            for side = 1:n_u
                nxt = mod(side, n_u) + 1;
                triangles(end + 1, :) = [south, last_start + nxt - 1, last_start + side - 1]; %#ok<AGROW>
            end
            points = points + center(:).';
            triangles = zef_orient_surface_outward(points, triangles);
        end
    end
end
