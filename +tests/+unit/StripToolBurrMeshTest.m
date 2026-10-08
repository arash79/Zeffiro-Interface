classdef StripToolBurrMeshTest < matlab.unittest.TestCase
%STRIPTOOLBURRMESHTEST  Burr holes before and after volumetric meshing.
%
%   A nested-cube model starts as surfaces. Mesh generation (process,
%   create, postprocess) consumes the lead specification. The same
%   specification applied afterwards to a mesh built with the option off
%   matches that result. Regenerating from surfaces uses the latest
%   radii even if a volumetric mesh is already stored.

    properties (Constant)
        IcbmFile = '/Users/hsc476/Documents/ICBM152_Models/FS_WS_SIMPLE_ICBM152_mesh_lead_field.mat'
    end

    methods (TestClassSetup)
        function addPaths(~)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(root);
            addpath(fullfile(root, 'plugins', 'StripTool'));
            addpath(genpath(fullfile(root, 'src')));
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
        function operationSelectsThePath(testCase)
            testCase.verifyEqual(zef_strip_burr_mode('generate'), 'fresh');
            testCase.verifyEqual(zef_strip_burr_mode('regenerate'), 'fresh');
            testCase.verifyEqual(zef_strip_burr_mode('apply'), 'reapply');
        end

        function meshGenerationFromSurfacesWritesConductivity(testCase)
            zef = tests.unit.StripToolBurrMeshTest.configured(true);
            testCase.verifyFalse(isfield(zef, 'tetra'));
            zef = tests.unit.StripToolBurrMeshTest.generate(zef);
            [inner_hit, outer_hit] = tests.unit.StripToolBurrMeshTest.hits(zef);
            testCase.verifyGreaterThan(numel(inner_hit), 0);
            testCase.verifyGreaterThan(numel(outer_hit), 0);
            testCase.verifyEqual(zef.sigma(inner_hit, 1), repmat(4, numel(inner_hit), 1));
            testCase.verifyEqual(zef.sigma(outer_hit, 1), repmat(8, numel(outer_hit), 1));
            testCase.verifyTrue(all(abs(zef.sigma(zef.domain_labels == 3, 1) - 0.05) < 1e-12));
            inner_rest = setdiff(find(zef.domain_labels == 1), inner_hit);
            outer_rest = setdiff(find(zef.domain_labels == 2), outer_hit);
            testCase.verifyGreaterThan(numel(inner_rest), 0);
            testCase.verifyGreaterThan(numel(outer_rest), 0);
            testCase.verifyEqual(zef.sigma(inner_rest, 1), ones(numel(inner_rest), 1));
            testCase.verifyEqual(zef.sigma(outer_rest, 1), repmat(0.2, numel(outer_rest), 1));
            testCase.verifyLessThanOrEqual( ...
                max(tests.unit.StripToolBurrMeshTest.radial(zef, 1, inner_hit)), 1.5 + 1e-8);
            testCase.verifyLessThanOrEqual( ...
                max(tests.unit.StripToolBurrMeshTest.radial(zef, 2, outer_hit)), 1.2 + 1e-8);
        end

        function postMeshUpdateMatchesGeneration(testCase)
            generated = tests.unit.StripToolBurrMeshTest.generate( ...
                tests.unit.StripToolBurrMeshTest.configured(true));
            plain = tests.unit.StripToolBurrMeshTest.configured(false);
            plain = tests.unit.StripToolBurrMeshTest.generate(plain);
            plain.s_strip_cell{1}.burr_hole_on = 1;
            plain.s_strip_cell{2}.burr_hole_on = 1;
            updated = zef_strip_apply_burr_holes(plain, zef_strip_burr_mode('apply'));
            testCase.verifyEqual(size(updated.tetra), size(generated.tetra));
            testCase.verifyEqual(updated.sigma(:, 1), generated.sigma(:, 1));
        end

        function regenerationIgnoresStaleVolume(testCase)
            zef = tests.unit.StripToolBurrMeshTest.generate( ...
                tests.unit.StripToolBurrMeshTest.configured(true));
            testCase.verifyGreaterThan(nnz(abs(zef.sigma(:, 1) - 8) < 1e-12), 0);
            zef.s_strip_cell{2}.burr_holes.conductivity = 6;
            zef.sigma(:, 1) = -1;
            zef.L = ones(3, 3);
            zef = tests.unit.StripToolBurrMeshTest.generate(zef);
            testCase.verifyGreaterThan(nnz(abs(zef.sigma(:, 1) - 6) < 1e-12), 0);
            testCase.verifyEqual(nnz(zef.sigma(:, 1) == -1), 0);
            testCase.verifyTrue(isempty(zef.L));
            testCase.verifyTrue(zef.strip_burr_report.lead_field_cleared);
            [~, outer_hit] = tests.unit.StripToolBurrMeshTest.hits(zef);
            testCase.verifyEqual(zef.sigma(outer_hit, 1), repmat(6, numel(outer_hit), 1));
        end

        function unresolvedRadiusIsNotApplied(testCase)
            zef = tests.unit.StripToolBurrMeshTest.generate( ...
                tests.unit.StripToolBurrMeshTest.configured(false));
            sigma_before = zef.sigma;
            zef.s_strip_cell{2}.burr_hole_on = 1;
            zef.s_strip_cell{2}.burr_holes.radius_mm = 0.2;
            zef.s_strip_cell{2}.burr_holes.conductivity = 8;
            [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
            testCase.verifyEqual(zef.sigma, sigma_before);
            testCase.verifyTrue(contains(strjoin(report.messages, ' '), 'Mesh resolution'));
            testCase.verifyTrue(contains(strjoin(report.messages, ' '), 'not increased'));
            testCase.verifyFalse(isempty(report.dialogs));
        end

        function specificationSurvivesSave(testCase)
            zef = tests.unit.StripToolBurrMeshTest.configured(true);
            file = [tempname '.mat'];
            testCase.addTeardown(@() delete_if_present(file));
            s_strip_cell = zef.s_strip_cell; %#ok<NASGU>
            current_sensors = zef.current_sensors; %#ok<NASGU>
            save(file, 's_strip_cell', 'current_sensors');
            loaded = load(file);
            testCase.verifyEqual(loaded.current_sensors, 's');
            testCase.verifyEqual(loaded.s_strip_cell{1}.burr_holes.compartment_tag, 'c_inner');
            testCase.verifyEqual(loaded.s_strip_cell{1}.burr_holes.radius_mm, 1.5);
            testCase.verifyEqual(loaded.s_strip_cell{2}.burr_holes.conductivity, 8);
        end

        function noticeDismissesOnOk(testCase)
            out_dir = '/tmp/zeffiro_burr_validation';
            if ~exist(out_dir, 'dir')
                mkdir(out_dir);
            end
            fig = zef_strip_burr_notice( ...
                ['Radius 0.2 mm is smaller than the mesh resolution 1 mm. ' ...
                'Create the FEM mesh again with a finer resolution, or increase the radius.'], ...
                'Wait', false);
            testCase.addTeardown(@() delete_if_figure(fig));
            button = findall(fig, 'Type', 'uibutton', 'Tag', 'zef_burr_notice_ok');
            testCase.verifyEqual(button.Text, 'OK');
            try
                exportapp(fig, fullfile(out_dir, 'burr_resolution_dialog.png'));
            catch
            end
            button.ButtonPushedFcn(button, []);
            testCase.verifyFalse(isgraphics(fig) && isvalid(fig));
        end

        function icbmFileHasSurfacesAndVolume(testCase)
            if ~isfile(tests.unit.StripToolBurrMeshTest.IcbmFile)
                testCase.assumeFail('ICBM project file is not on this machine.');
            end
            listing = whos('-file', tests.unit.StripToolBurrMeshTest.IcbmFile);
            names = {listing.name};
            testCase.verifyTrue(ismember('tetra', names));
            testCase.verifyTrue(ismember('nodes', names));
            testCase.verifyTrue(ismember('sigma', names));
            testCase.verifyTrue(ismember('c8_points', names));
            testCase.verifyTrue(ismember('c8_triangles', names));
            testCase.verifyTrue(ismember('compartment_tags', names));
        end
    end

    methods (Static, Access = private)
        function zef = configured(enabled)
            zef = tests.support.createSyntheticMeshZef();
            zef.gpu_num = 0;
            zef.use_display = false;
            zef.mesh_resolution = 1;
            zef.mesh_smoothing_on = 0;
            zef.exclude_box = 0;
            zef.refinement_surface_on_2 = 0;
            zef.refinement_surface_number_2 = 0;
            zef.refinement_volume_on_2 = 0;
            zef.mesh_optimization_parameter = 10;
            zef.mesh_optimization_repetitions = 1;
            zef.parameter_profile = { ...
                'Electrical conductivity', 'sigma', 'Scalar', 0.33, 'S/m', 'On', 'On', 'Segmentation'};
            [p_inner, t_inner] = tests.unit.StripToolBurrMeshTest.cube([6 6 0], [8 8 20]);
            [p_outer, t_outer] = tests.unit.StripToolBurrMeshTest.cube([0 0 0], [20 20 20]);
            [p_wrap, t_wrap] = tests.unit.StripToolBurrMeshTest.cube([-4 -4 -2], [28 28 24]);
            zef = tests.unit.StripToolBurrMeshTest.addCompartment( ...
                zef, 'c_inner', 'Inner', 1, p_inner, t_inner);
            zef = tests.unit.StripToolBurrMeshTest.addCompartment( ...
                zef, 'c_outer', 'Outer', 0.2, p_outer, t_outer);
            zef = tests.unit.StripToolBurrMeshTest.addCompartment( ...
                zef, 'c_wrap', 'Wrap', 0.05, p_wrap, t_wrap);
            zef.compartment_tags = {'c_inner', 'c_outer', 'c_wrap'};
            center = tests.unit.StripToolBurrMeshTest.lead(1, [10; 10; 0], 'c_inner', 1.5, 4);
            wall = tests.unit.StripToolBurrMeshTest.lead(2, [2.5; 10; 0], 'c_outer', 1.2, 8);
            if ~enabled
                center.burr_hole_on = 0;
                wall.burr_hole_on = 0;
            end
            zef.s_strip_cell = {center, wall};
        end

        function zef = generate(zef)
            zef.use_display = false;
            zef = zef_process_meshes(zef);
            zef = zef_create_fem_mesh(zef);
            zef = zef_postprocess_fem_mesh(zef);
        end

        function lead = lead(id, tip, tag, radius_mm, conductivity)
            lead = struct();
            lead.strip_model = 4;
            lead.orientation_axis = {[0; 0; 1], [0; 0; 1]};
            lead.tip_point = tip;
            lead.strip_angle = 0;
            lead.strip_length = 20;
            lead.encapsulation_length = 20;
            lead.encapsulation_thickness = 0.5;
            lead.encapsulation_on = 0;
            lead.encapsulation_shift = [0; 0; 0];
            lead.strip_n_sectors = 12;
            lead.strip_id = id;
            lead.strip_tag = tag;
            lead.strip_status = 'Tentative';
            lead.burr_hole_on = 1;
            lead.burr_holes = struct('compartment_tag', tag, ...
                'radius_mm', radius_mm, 'conductivity', conductivity);
        end

        function [inner_hit, outer_hit] = hits(zef)
            inner_hit = tests.unit.StripToolBurrMeshTest.inside(zef, 1, 1, 1.5);
            outer_hit = tests.unit.StripToolBurrMeshTest.inside(zef, 2, 2, 1.2);
        end

        function index = inside(zef, strip_index, domain_id, radius_mm)
            strip = zef_create_strip(zef.s_strip_cell{strip_index});
            sel = find(zef.domain_labels == domain_id);
            tet = zef.tetra(sel, :);
            centroid = (zef.nodes(tet(:, 1), :) + zef.nodes(tet(:, 2), :) ...
                + zef.nodes(tet(:, 3), :) + zef.nodes(tet(:, 4), :)) * 0.25;
            local = zef_strip_lead_frame(strip, centroid);
            radial = hypot(local(:, 1), local(:, 2));
            axial = local(:, 3);
            tol = 1e-8;
            index = sel(radial <= radius_mm + tol & axial >= -tol & axial <= strip.strip_length + tol);
        end

        function radial = radial(zef, strip_index, index)
            strip = zef_create_strip(zef.s_strip_cell{strip_index});
            tet = zef.tetra(index, :);
            centroid = (zef.nodes(tet(:, 1), :) + zef.nodes(tet(:, 2), :) ...
                + zef.nodes(tet(:, 3), :) + zef.nodes(tet(:, 4), :)) * 0.25;
            local = zef_strip_lead_frame(strip, centroid);
            radial = hypot(local(:, 1), local(:, 2));
        end

        function [points, triangles] = cube(origin, size_xyz)
            unit_points = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            triangles = [1 4 3; 1 3 2; 5 6 7; 5 7 8; 1 2 6; 1 6 5; ...
                4 8 7; 4 7 3; 1 5 8; 1 8 4; 2 3 7; 2 7 6];
            points = unit_points .* size_xyz(:).' + origin(:).';
        end

        function zef = addCompartment(zef, tag, name, sigma, points, triangles)
            zef.([tag '_on']) = 1;
            zef.([tag '_name']) = name;
            zef.([tag '_sigma']) = sigma;
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
        end
    end
end

function delete_if_present(file)
if isfile(file)
    delete(file);
end
end

function delete_if_figure(fig)
if ~isempty(fig) && isgraphics(fig) && isvalid(fig)
    delete(fig);
end
end
