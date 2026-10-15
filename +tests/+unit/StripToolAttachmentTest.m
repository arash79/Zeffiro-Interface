classdef StripToolAttachmentTest < matlab.unittest.TestCase
%STRIPTOOLATTACHMENTTEST  Scalp attachment stays off an implanted shaft.

    methods (TestClassSetup)
        function addPaths(~)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(fullfile(root, 'plugins', 'StripTool'));
            addpath(genpath(fullfile(root, 'src')));
        end
    end

    methods (Test)
        function scalpPointStaysOffTheShaft(testCase)
            [zef, sensors] = tests.unit.StripToolAttachmentTest.project();
            attached = zef_attach_sensors_volume(zef, sensors, 'mesh');
            scalp_row = attached(attached(:, 1) == 1, :);
            testCase.verifyEqual(scalp_row, [1 2 1 0]);
            zef.scalp_visible = 0;
            zef.shaft_visible = 1;
            again = zef_attach_sensors_volume(zef, sensors, 'mesh');
            testCase.verifyEqual(again, attached);
            zef.scalp_visible = 1;
            third = zef_attach_sensors_volume(zef, sensors, 'mesh');
            testCase.verifyEqual(third, attached);
        end

        function shaftContactIsNotMovedOntoTheScalp(testCase)
            [zef, sensors] = tests.unit.StripToolAttachmentTest.project();
            zef.s2_get_functions = {'', 'deal([10 11 12], struct(), [])'};
            sensors = [sensors; sensors(1, :)];
            zef.s2_points = [zef.s2_points; zef.s2_points];
            attached = zef_attach_sensors_volume(zef, sensors, 'mesh');
            testCase.verifyEqual(attached(attached(:, 1) == 2, :), [2 10 11 12]);
            testCase.verifyEqual(attached(attached(:, 1) == 1, :), [1 2 1 0]);
        end

        function contactFacesStayDistinctFromTheShaftBody(testCase)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(fullfile(root, 'plugins', 'StripTool'));
            strip_struct = zef_create_strip(tests.unit.StripToolAttachmentTest.baseStrip(4));
            zef = struct('sensor_tags', {{'s2'}});
            strip_struct.compartment_tag = {'shaft'};
            zef.s2_strip_cell = {strip_struct};
            [body, active, inactive] = zef_strip_face_sets( ...
                zef, 'shaft', strip_struct.points{1}, strip_struct.triangles{1});
            testCase.verifyGreaterThan(size(active, 1), 0);
            testCase.verifyGreaterThan(size(inactive, 1), 0);
            testCase.verifyEqual(size(body, 1) + size(active, 1) + size(inactive, 1), size(strip_struct.triangles{1}, 1));
            testCase.verifyEmpty(intersect(active, inactive, 'rows'));
            [~, active_only] = zef_strip_face_sets(zef, 'scalp', strip_struct.points{1}, strip_struct.triangles{1});
            testCase.verifyEmpty(active_only);
        end

        function plottedPlacementIsWhatEmbeddingStores(testCase)
            % The compartment mesh is the forward transform of the tip the
            % user set. A head translation must not be baked into that tip.
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(fullfile(root, 'plugins', 'StripTool'));
            strip_struct = tests.unit.StripToolAttachmentTest.baseStrip(4);
            strip_struct.tip_point = [5; -12; 40];
            strip_struct.encapsulation_on = 1;
            strip_struct.encapsulation_shift = [0; 0; 0];
            strip_struct = zef_create_strip(strip_struct);
            world = zef_strip_coordinate_transform(strip_struct, 'forward');
            again = zef_strip_coordinate_transform(strip_struct, 'forward');
            testCase.verifyLessThan(max(abs(world{1}(:) - again{1}(:))), 1e-9);
            testCase.verifyEqual(strip_struct.tip_point, [5; -12; 40]);
            testCase.verifyGreaterThan(min(world{1}(:, 3)), 39);
            testCase.verifyLessThan(max(world{1}(:, 3)), 40 + strip_struct.strip_length + 1);
        end

        function diskModelsKeepSeparateBarycentricSamples(testCase)
            for model = [4 5]
                [faces, info] = tests.unit.StripToolAttachmentTest.coarseContact(model, 1);
                testCase.verifyEqual(info.electrode_representation, 'point_barycentric');
                testCase.verifySize(faces, [4 3]);
                testCase.verifyEqual(sum(faces(:, 2)), 1, 'AbsTol', 1e-8);
                testCase.verifyEqual(faces(:, 3), zeros(4, 1));
                other = tests.unit.StripToolAttachmentTest.coarseContact(model, 5);
                testCase.verifyGreaterThan(norm(faces(:, 1:2) - other(:, 1:2)), 0);
                passed = zef_pem2cem([ones(4, 1), faces], [1 2 3 4]);
                testCase.verifyEqual(passed, [ones(4, 1), faces]);
            end
        end
    end

    methods (Static, Access = private)
        function [zef, sensors] = project()
            shaft_cloud = [-7.7 -10.8 102; -8 -11 101; -7.5 -10.5 101.5];
            scalp_cloud = [5.5 -12.4 102.7; 0 0 90; 20 10 40];
            box_cloud = [200 0 0; 0 200 0; 0 0 200];
            zef = struct();
            zef.imaging_method = 1;
            zef.current_sensors = 's2';
            zef.use_depth_electrodes = 0;
            zef.sensor_tags = {'s2'};
            zef.compartment_tags = {'shaft', 'scalp', 'box'};
            zef.reuna_p = {shaft_cloud, scalp_cloud, box_cloud};
            zef.reuna_t = {[1 2 3], [1 2 3], [1 2 3]};
            zef.reuna_type = {0, 'inactive', 1, 'shaft'; 0, 'inactive', 2, 'scalp'; -1, 'box', 3, 'box'};
            zef.s2_electrode_surface_index = 1;
            zef.s2_strip_cell = {struct('compartment_tag', {{'shaft'}})};
            zef.nodes = [-7.7 -10.8 102; 6.9 -9.9 81; 0 0 0; 1 0 0];
            zef.tetra = [1 2 3 4];
            zef.surface_triangles = {[1 1 2]};
            sensor = [7.3 -9.7 117];
            zef.s2_points = sensor;
            zef.s2_get_functions = {''};
            zef.scalp_visible = 1;
            zef.shaft_visible = 1;
            sensors = [sensor, 0, 1, 1000];
        end

        function strip_struct = baseStrip(model)
            strip_struct = struct();
            strip_struct.strip_model = model;
            strip_struct.orientation_axis = {[0; 0; 1], [0; 0; 1]};
            strip_struct.tip_point = [0; 0; 0];
            strip_struct.strip_angle = 0;
            strip_struct.strip_length = 4;
            strip_struct.encapsulation_length = 4;
            strip_struct.encapsulation_thickness = 0.1;
            strip_struct.encapsulation_on = 0;
            strip_struct.strip_n_sectors = 16;
            strip_struct.strip_id = 1;
        end

        function [faces, info] = coarseContact(model, channel)
            strip_struct = zef_create_strip(tests.unit.StripToolAttachmentTest.baseStrip(model));
            strip_struct.compartment_tag = {'lead'};
            [x, y, z] = ndgrid(-2:1:2, -2:1:2, -1:1:2);
            cloud = [x(:), y(:), z(:)];
            triangulation = delaunayTriangulation(cloud);
            zef = struct();
            zef.compartment_tags = {'lead'};
            zef.nodes = triangulation.Points;
            zef.tetra = triangulation.ConnectivityList;
            zef.surface_triangles = {triangulation.freeBoundary()};
            [faces, info] = zef_get_strip_contacts(channel, strip_struct, zef, 'mesh');
        end
    end
end
