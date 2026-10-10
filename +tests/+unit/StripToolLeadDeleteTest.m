classdef StripToolLeadDeleteTest < matlab.unittest.TestCase
%STRIPTOOLLEADDELETETEST  Deleting a lead removes its electrode contacts.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   DiSC-64, DiSC-128, a legacy 4-contact lead, and one unrelated scalp
%   electrode share a sensor set. Delete must drop only the selected
%   lead's rows, retarget the other leads' get_functions, clear the
%   cached lead field, and remove that lead from the Figure tool.

    methods (TestClassSetup)
        function addPaths(~)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(fullfile(root, 'plugins', 'StripTool'));
            addpath(fullfile(root, 'src', 'gui', 'chrome'));
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
        function deletingDisc64ThenDisc128LeavesTheOtherElectrodes(testCase)
            [zef, figures] = tests.unit.StripToolLeadDeleteTest.openOrSkip(testCase);
            testCase.addTeardown(@() tests.unit.StripToolLeadDeleteTest.closeFigures(figures));
            zef = tests.unit.StripToolLeadDeleteTest.addLeadContacts(zef);

            disc64 = zef_get_strip_contacts(1, zef.s_strip_cell{1}, struct(), 'points');
            disc128 = zeros(128, 3);
            omni = zeros(4, 3);
            for channel = 1:128
                disc128(channel, :) = zef_get_strip_contacts(channel, zef.s_strip_cell{2}, struct(), 'points');
            end
            for channel = 1:4
                omni(channel, :) = zef_get_strip_contacts(channel, zef.s_strip_cell{3}, struct(), 'points');
            end
            testCase.verifyEqual(size(zef.s_points, 1), 197);
            testCase.verifyEqual(zef.s_points(1, :), [20 0 0], 'AbsTol', 1e-12);
            testCase.verifyEqual(zef.s_points(2:65, :), tests.unit.StripToolLeadDeleteTest.contactBlock(zef.s_strip_cell{1}), 'AbsTol', 1e-8);
            testCase.verifyEqual(zef.s_points(66:193, :), disc128, 'AbsTol', 1e-8);
            testCase.verifyEqual(zef.s_points(194:197, :), omni, 'AbsTol', 1e-8);

            zef.strip_tool.current_strip = 1;
            zef_strip_tool_plot(zef);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'additional: strip contact'), 64);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'additional: strip contact inactive'), 64);
            zef.strip_tool.current_strip = 2;
            zef_strip_tool_plot(zef);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'additional: strip contact'), 128);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'additional: strip contact inactive'), 0);
            ids = tests.unit.StripToolLeadDeleteTest.previewIds(zef);
            testCase.verifyEqual(unique(ids), 2);

            glyphs = tests.unit.StripToolLeadDeleteTest.drawElectrodes(zef);
            shot_dir = tests.unit.StripToolLeadDeleteTest.shotDir();
            tests.unit.StripToolLeadDeleteTest.shot(zef, fullfile(shot_dir, 'delete_before.png'), 'Before delete');

            stale_L = zef.L;
            testCase.verifySize(stale_L, [197 3]);
            zef.strip_tool.current_strip = 1;
            zef = zef_strip_tool_delete(zef);

            testCase.verifyEqual(size(zef.s_points, 1), 133);
            testCase.verifyEqual(zef.s_points(1, :), [20 0 0], 'AbsTol', 1e-12);
            testCase.verifyEqual(zef.s_points(2:129, :), disc128, 'AbsTol', 1e-8);
            testCase.verifyEqual(zef.s_points(130:133, :), omni, 'AbsTol', 1e-8);
            testCase.verifyGreaterThan(min(sqrt(sum((zef.s_points - disc64).^2, 2))), 1);
            testCase.verifyEqual(zef.s_name_list{1}, 'scalp');
            testCase.verifyEqual(zef.s_electrode_impedance(1), 2000);
            testCase.verifyEqual(zef.s_electrode_impedance(2), 1000);
            testCase.verifyEmpty(zef.L);
            testCase.verifyEmpty(zef.sensors_attached_volume);
            testCase.verifyEmpty(zef.inv_bg_data);
            testCase.verifySize(zef.sensors, [133 6]);
            testCase.verifyEqual(numel(zef.s_strip_cell), 2);
            testCase.verifyEqual(zef.s_strip_cell{1}.strip_id, 2);
            testCase.verifyEqual(zef.s_strip_cell{1}.strip_model, 5);
            testCase.verifyEqual(zef.s_strip_cell{1}.tip_point(:), [6; 0; 0]);
            testCase.verifyEqual(zef.s_strip_cell{2}.strip_id, 3);
            testCase.verifyEqual(zef.s_strip_cell{2}.strip_model, 1);
            testCase.verifyEqual(size(zef.h_sensors_name_table.Data, 1), 133);
            tests.unit.StripToolLeadDeleteTest.verifyFunctions(testCase, zef, [0 2 3]);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'sensor'), 133);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'sensor_name'), 1);
            testCase.verifyFalse(isgraphics(glyphs.disc64));
            testCase.verifyTrue(isgraphics(glyphs.scalp));
            testCase.verifyTrue(isgraphics(glyphs.disc128));
            testCase.verifyEqual(glyphs.scalp.UserData.sensor_index, 1);
            testCase.verifyEqual(glyphs.disc128.UserData.sensor_index, 2);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.previewIds(zef), ...
                2 * ones(129, 1));
            tests.unit.StripToolLeadDeleteTest.shot(zef, fullfile(shot_dir, 'delete_after_disc64.png'), 'After DiSC-64 delete');
            tests.unit.StripToolLeadDeleteTest.verifyLeadField(testCase, zef.s_strip_cell{1}, zef.s_points(2:129, :), zef.s_get_functions(2:129));

            zef.strip_tool.current_strip = 1;
            zef = zef_strip_tool_delete(zef);
            testCase.verifyEqual(size(zef.s_points, 1), 5);
            testCase.verifyEqual(zef.s_points(1, :), [20 0 0], 'AbsTol', 1e-12);
            testCase.verifyEqual(zef.s_points(2:5, :), omni, 'AbsTol', 1e-8);
            testCase.verifyEqual(numel(zef.s_strip_cell), 1);
            testCase.verifyEqual(zef.s_strip_cell{1}.strip_model, 1);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'additional: strip contact'), 0);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'additional: strip'), 0);
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'sensor'), 5);
            tests.unit.StripToolLeadDeleteTest.verifyFunctions(testCase, zef, [0 3]);
            tests.unit.StripToolLeadDeleteTest.shot(zef, fullfile(shot_dir, 'delete_after_disc128.png'), 'After DiSC-128 delete');

            zef.strip_tool.current_strip = 1;
            zef = zef_strip_tool_delete(zef);
            testCase.verifyEqual(size(zef.s_points, 1), 1);
            testCase.verifyEqual(zef.s_points, [20 0 0], 'AbsTol', 1e-12);
            testCase.verifyEqual(zef.s_name_list{1}, 'scalp');
            testCase.verifyEqual(char(zef.s_get_functions{1}), 'error(''zef:NotAStrip'',''scalp'');');
            testCase.verifyEqual(tests.unit.StripToolLeadDeleteTest.countTag(zef, 'sensor'), 1);
        end

        function deletingTheSecondLeadKeepsTheFirst(testCase)
            [zef, figures] = tests.unit.StripToolLeadDeleteTest.openOrSkip(testCase);
            testCase.addTeardown(@() tests.unit.StripToolLeadDeleteTest.closeFigures(figures));
            zef = tests.unit.StripToolLeadDeleteTest.addLeadContacts(zef);
            disc64 = tests.unit.StripToolLeadDeleteTest.contactBlock(zef.s_strip_cell{1});
            omni = zeros(4, 3);
            for channel = 1:4
                omni(channel, :) = zef_get_strip_contacts(channel, zef.s_strip_cell{3}, struct(), 'points');
            end
            zef.strip_tool.current_strip = 2;
            zef = zef_strip_tool_delete(zef);
            testCase.verifyEqual(size(zef.s_points, 1), 69);
            testCase.verifyEqual(zef.s_points(2:65, :), disc64, 'AbsTol', 1e-8);
            testCase.verifyEqual(zef.s_points(66:69, :), omni, 'AbsTol', 1e-8);
            testCase.verifyEqual(zef.s_strip_cell{1}.strip_id, 1);
            testCase.verifyEqual(zef.s_strip_cell{1}.strip_model, 4);
            testCase.verifyEqual(zef.s_strip_cell{1}.tip_point(:), [0; 0; 0]);
            testCase.verifyEqual(zef.s_strip_cell{2}.strip_model, 1);
            tests.unit.StripToolLeadDeleteTest.verifyFunctions(testCase, zef, [0 1 3]);
            testCase.verifyEqual(numel(zef.s_get_functions), 69);
        end

        function repeatedCreateAndDeleteDoesNotAccumulateContacts(testCase)
            [zef, figures] = tests.unit.StripToolLeadDeleteTest.openOrSkip(testCase);
            testCase.addTeardown(@() tests.unit.StripToolLeadDeleteTest.closeFigures(figures));
            zef.L = [1 2 3];
            for cycle = 1:2
                for model = [4 5]
                    before = size(zef.s_points, 1);
                    zef = zef_strip_tool_add(zef);
                    slot = zef.strip_tool.current_strip;
                    zef.s_strip_cell{slot}.strip_model = model;
                    zef.s_strip_cell{slot}.tip_point = [3 * model; 0; 0];
                    zef = zef_strip_tool_init(zef);
                    zef = zef_strip_tool_update(zef);
                    zef = zef_strip_tool_add_contacts(zef);
                    expected = before + zef.s_strip_cell{zef.strip_tool.current_strip}.strip_n_contacts;
                    testCase.verifyEqual(size(zef.s_points, 1), expected);
                    zef.L = rand(expected, 2);
                    zef.sensors_attached_volume = [(1:expected)' zeros(expected, 3)];
                    zef.strip_tool.current_strip = numel(zef.s_strip_cell);
                    zef = zef_strip_tool_delete(zef);
                    testCase.verifyEqual(size(zef.s_points, 1), before);
                    testCase.verifyEqual(zef.s_points(1, :), [20 0 0], 'AbsTol', 1e-12);
                    testCase.verifyEmpty(zef.L);
                    testCase.verifyEmpty(zef.sensors_attached_volume);
                end
            end
            zef.L = [4 5 6];
            zef.sensors_attached_volume = [9 9 9 9];
            zef = zef_strip_tool_add(zef);
            zef.strip_tool.current_strip = numel(zef.s_strip_cell);
            zef = zef_strip_tool_delete(zef);
            testCase.verifyEqual(zef.L, [4 5 6]);
            testCase.verifyEqual(zef.sensors_attached_volume, [9 9 9 9]);
            testCase.verifyEqual(size(zef.s_points, 1), 1);
        end

        function sensorGraphicStampUsesTheProjectRow(testCase)
            figure_handle = figure('Visible', 'off');
            testCase.addTeardown(@() delete(figure_handle));
            axes_handle = axes('Parent', figure_handle);
            [sx, sy, sz] = sphere(4);
            glyph = surf(axes_handle, sx, sy, sz);
            zef_mark_sensor_graphic(glyph, [4; 9], 2);
            testCase.verifyEqual(glyph.UserData.sensor_index, 9);
            zef_mark_sensor_graphic(glyph, [], 3);
            testCase.verifyEqual(glyph.UserData.sensor_index, 3);
        end

        function sensorGraphicStampAcceptsNumericHandle(testCase)
            % trisurf assigned into a double array becomes a numeric handle.
            % isgraphics accepts it; dot assignment does not.
            figure_handle = figure('Visible', 'off');
            testCase.addTeardown(@() delete(figure_handle));
            axes_handle = axes('Parent', figure_handle);
            patch_handle = trisurf([1 2 3], [0 1 0], [0 0 1], [0 0 0], 'Parent', axes_handle);
            stored = zeros(1, 1);
            stored(1) = patch_handle;
            testCase.verifyClass(stored, 'double');
            testCase.verifyTrue(isgraphics(stored(1)));
            zef_mark_sensor_graphic(stored(1), [4; 9], 2);
            stamped = findobj(axes_handle, 'Type', 'Patch');
            testCase.verifyEqual(stamped.UserData.sensor_index, 9);
            root_data = get(groot, 'UserData');
            zef_mark_sensor_graphic(0, [], 1);
            testCase.verifyEqual(get(groot, 'UserData'), root_data);
        end
    end

    methods (Static, Access = private)
        function [zef, figures] = openSession()
            old_vis = get(0, 'DefaultFigureVisible');
            cleaner = onCleanup(@() set(0, 'DefaultFigureVisible', old_vis)); %#ok<NASGU>
            set(0, 'DefaultFigureVisible', 'off');
            zef = struct();
            zef.current_sensors = 's';
            zef.strip_tool = struct();
            zef.strip_tool.strip_current_id = 1;
            try
                zef = zef_strip_tool_window(zef);
            catch ME
                if tests.unit.StripToolLeadDeleteTest.displayMissing(ME)
                    error('zef:NoDisplay', 'No display available for the Strip tool figure.');
                end
                rethrow(ME);
            end
            name_figure = figure('Visible', 'off');
            zef.h_sensors_name_table = uitable(name_figure, 'Data', cell(0, 3));
            view_figure = figure('Visible', 'off', 'Name', 'ZEFFIRO Interface: Figure tool', ...
                'Color', [0.82 0.82 0.82], 'Position', [40 40 980 720]);
            zef.h_axes1 = axes('Parent', view_figure, 'Color', [0.86 0.86 0.86]);
            hold(zef.h_axes1, 'on');
            axis(zef.h_axes1, 'equal');
            grid(zef.h_axes1, 'on');
            view(zef.h_axes1, 28, 18);
            figures = [zef.strip_tool.h_window, name_figure, view_figure];

            zef.s_points = [20 0 0];
            zef.s_electrode_impedance = 2000;
            zef.s_electrode_inner_radius = 0;
            zef.s_electrode_outer_radius = 0;
            zef.s_name_list = {'scalp'};
            zef.s_visible_list = 1;
            zef.s_visible = 1;
            zef.s_color = [0.85 0.15 0.15];
            zef.s_color_table = zef.s_color;
            zef.s_get_functions = {[]};
            zef.s_directions = [];
            zef.parameter_profile = { ...
                'Electrode impedance', 'electrode_impedance', 'Scalar', 2000, 'Ohm', 'On', 'On', 'Sensors'; ...
                'Electrode outer radius', 'electrode_outer_radius', 'Scalar', 0, 'mm', 'On', 'On', 'Sensors'; ...
                'Electrode inner radius', 'electrode_inner_radius', 'Scalar', 1, 'mm', 'On', 'On', 'Sensors'};
            zef.s_strip_cell = { ...
                tests.unit.StripToolLeadDeleteTest.lead(4, 1, [0; 0; 0], 'DiSC64'), ...
                tests.unit.StripToolLeadDeleteTest.lead(5, 2, [6; 0; 0], 'DiSC128'), ...
                tests.unit.StripToolLeadDeleteTest.lead(1, 3, [12; 0; 0], 'Omni4')};
            zef.strip_tool.strip_current_id = 3;
        end

        function zef = addLeadContacts(zef)
            for index = 1:numel(zef.s_strip_cell)
                zef.strip_tool.current_strip = index;
                zef = zef_strip_tool_add_contacts(zef);
            end
            zef.s_get_functions{1} = 'error(''zef:NotAStrip'',''scalp'');';
            n = size(zef.s_points, 1);
            zef.L = rand(n, 3);
            zef.inv_bg_data = rand(n, 1);
            zef.sensors_attached_volume = [(1:n)' zeros(n, 3)];
            zef.sensors = [zef.s_points zeros(n, 3)];
        end

        function lead = lead(model, id, tip, tag)
            lead = struct();
            lead.strip_model = model;
            lead.orientation_axis = {[0; 0; 1], [0; 0; 1]};
            lead.tip_point = tip;
            lead.encapsulation_shift = [0; 0; 0];
            lead.strip_angle = 0;
            lead.strip_length = 8;
            lead.encapsulation_length = 8;
            lead.encapsulation_thickness = 0.5;
            lead.encapsulation_on = 0;
            lead.strip_n_sectors = 12;
            lead.strip_id = id;
            lead.strip_tag = tag;
            lead.strip_status = 'Tentative';
            lead.strip_impedance = 1000;
            lead.strip_conductivity = 1e-15;
            lead.encapsulation_conductivity = 0.33;
            lead.strip_mode = '1';
        end

        function glyphs = drawElectrodes(zef)
            axes(zef.h_axes1); %#ok<LAXES>
            hold(zef.h_axes1, 'on');
            [sx, sy, sz] = sphere(6);
            scale = 0.18;
            colors = [0.85 0.15 0.15; 0.95 0.75 0.1; 0.1 0.45 0.85; 0.15 0.65 0.25];
            n = size(zef.s_points, 1);
            lead_of = ones(n, 1);
            lead_of(2:65) = 2;
            lead_of(66:193) = 3;
            lead_of(194:197) = 4;
            glyphs = struct('scalp', [], 'disc64', [], 'disc128', []);
            for index = 1:n
                center = zef.s_points(index, :);
                glyph = surf(zef.h_axes1, scale * sx + center(1), scale * sy + center(2), scale * sz + center(3));
                glyph.Tag = 'sensor';
                glyph.EdgeColor = 'none';
                glyph.FaceColor = colors(lead_of(index), :);
                zef_mark_sensor_graphic(glyph, [], index);
                if index == 1
                    glyphs.scalp = glyph;
                    label = text(zef.h_axes1, center(1), center(2), center(3) + 0.4, 'scalp');
                    label.Tag = 'sensor_name';
                    zef_mark_sensor_graphic(label, [], index);
                elseif index == 2
                    glyphs.disc64 = glyph;
                    label = text(zef.h_axes1, center(1), center(2), center(3) + 0.4, 'disc64');
                    label.Tag = 'sensor_name';
                    zef_mark_sensor_graphic(label, [], index);
                elseif index == 66
                    glyphs.disc128 = glyph;
                end
            end
            xlim(zef.h_axes1, [-2 22]);
            ylim(zef.h_axes1, [-4 4]);
            zlim(zef.h_axes1, [-1 9]);
        end

        function verifyFunctions(testCase, zef, expected_ids)
            % expected_ids(1) is the scalp sentinel 0. Later entries are
            % the strip_id of each remaining lead, in sensor-row order.
            seen = zeros(1, numel(zef.s_get_functions));
            for index = 1:numel(zef.s_get_functions)
                fn = zef.s_get_functions{index};
                if isempty(fn)
                    seen(index) = 0;
                    continue
                end
                fn = char(fn);
                if contains(fn, 'NotAStrip')
                    seen(index) = 0;
                    continue
                end
                [~, info] = zef_sensor_get_function_eval(fn, zef, 'sensor_info');
                seen(index) = info.strip_id;
                bound = regexp(fn, 's_strip_cell\{(\d+)\}', 'tokens', 'once');
                testCase.verifyNotEmpty(bound);
                slot = str2double(bound{1});
                testCase.verifyLessThanOrEqual(slot, numel(zef.s_strip_cell));
                testCase.verifyEqual(zef.s_strip_cell{slot}.strip_id, info.strip_id);
            end
            blocks = unique(seen, 'stable');
            testCase.verifyEqual(blocks, expected_ids);
        end

        function verifyLeadField(testCase, lead, points, functions)
            lead.compartment_tag = {'lead'};
            % Embedded compartments store the forward (world) surface.
            % The mesh query reverses that frame before cutting the disk.
            world = zef_strip_coordinate_transform(lead, 'forward');
            project = struct();
            project.imaging_method = 1;
            project.current_sensors = 's';
            project.use_depth_electrodes = 1;
            project.compartment_tags = {'lead'};
            project.reuna_type = {1};
            project.reuna_p = world(1);
            project.reuna_t = lead.triangles(1);
            project.nodes = world{1};
            project.surface_triangles = lead.triangles(1);
            project.tetra = [1 2 3 4];
            project.s_points = points;
            project.s_electrode_inner_radius = zeros(size(points, 1), 1);
            project.s_electrode_outer_radius = zeros(size(points, 1), 1);
            project.s_electrode_impedance = 1000 * ones(size(points, 1), 1);
            project.s_get_functions = functions;
            project.s_strip_cell = {lead};
            sensors = zef_cem_electrode(project, points);
            attached = zef_attach_sensors_volume(project, sensors, 'mesh');
            testCase.verifyEqual(unique(attached(:, 1))', 1:size(points, 1));
            aux = zef_lead_field_sensors_aux(1, sensors, attached);
            testCase.verifyEqual(aux, attached);
            rows = attached(attached(:, 1) == 1, 2:4);
            faces = zef_get_strip_contacts(1, lead, project, 'model_geometry');
            testCase.verifyEqual(sortrows(rows), sortrows(faces));
            for channel = 1:size(points, 1)
                [~, info] = zef_sensor_get_function_eval(functions{channel}, project, 'sensor_info');
                testCase.verifyEqual(info.strip_id, lead.strip_id);
            end
            [~, mesh_info] = zef_sensor_get_function_eval(functions{1}, project, 'mesh');
            testCase.verifyEqual(mesh_info.electrode_representation, 'finite_area');
        end

        function n = countTag(zef, tag)
            n = numel(findobj(zef.h_axes1, 'Tag', tag));
        end

        function ids = previewIds(zef)
            objects = findobj(zef.h_axes1, '-regexp', 'Tag', '^additional: strip');
            ids = zeros(numel(objects), 1);
            for index = 1:numel(objects)
                ids(index) = objects(index).UserData.strip_id;
            end
        end

        function shot(zef, path, label)
            title(zef.h_axes1, label);
            exportgraphics(zef.h_axes1.Parent, path, 'Resolution', 90);
        end

        function points = contactBlock(lead)
            if ~isfield(lead, 'strip_n_contacts') || isempty(lead.strip_n_contacts)
                lead = zef_get_strip_parameters(lead);
            end
            points = zeros(lead.strip_n_contacts, 3);
            for channel = 1:lead.strip_n_contacts
                points(channel, :) = zef_get_strip_contacts(channel, lead, struct(), 'points');
            end
        end

        function [zef, figures] = openOrSkip(testCase)
            try
                [zef, figures] = tests.unit.StripToolLeadDeleteTest.openSession();
            catch ME
                if strcmp(ME.identifier, 'zef:NoDisplay') || tests.unit.StripToolLeadDeleteTest.displayMissing(ME)
                    testCase.assumeFail(ME.message);
                end
                rethrow(ME);
            end
        end

        function directory = shotDir()
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            directory = fullfile(root, 'plugins', 'StripTool', 'validation');
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
        end

        function closeFigures(figures)
            for index = 1:numel(figures)
                if isgraphics(figures(index))
                    delete(figures(index));
                end
            end
        end

        function tf = displayMissing(ME)
            id = lower(char(string(ME.identifier)));
            msg = lower(char(string(ME.message)));
            tf = contains(id, 'display') || contains(msg, 'display') || contains(msg, 'no java');
        end
    end
end
