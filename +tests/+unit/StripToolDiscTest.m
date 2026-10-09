classdef StripToolDiscTest < matlab.unittest.TestCase
%STRIPTOOLDISCTEST  DiSC-64 and DiSC-128 against the published designs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Expected coordinates are computed from the cited dimensions, not
%   copied out of zef_strip_disc_lattice. Model 4 is Shores et al.
%   2026 (32 by 4 physical sites, every other diamond wired, 0.230 mm
%   row pitch, 0.800 mm shaft). Model 5 is the Abrego et al. 2023
%   G-128 wrap (16 by 8, 0.080 mm sites, 0.200 / 0.250 mm pitches,
%   0.674 mm shaft).

    methods (TestClassSetup)
        function addStripToolPath(~)
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
        function legacyModelsKeepRadiusAndContactCount(testCase)
            expected_n = [4 8 40];
            for model = 1:3
                s = tests.unit.StripToolDiscTest.parameters(model);
                testCase.verifyEqual(s.strip_radius, 0.635);
                testCase.verifyEqual(s.strip_n_contacts, expected_n(model));
            end
        end

        function discModelsUseTheirOwnShafts(testCase)
            s4 = tests.unit.StripToolDiscTest.parameters(4);
            s5 = tests.unit.StripToolDiscTest.parameters(5);
            testCase.verifyEqual(s4.strip_radius, 0.800 / 2, 'AbsTol', 1e-12);
            testCase.verifyEqual(s5.strip_radius, 0.674 / 2, 'AbsTol', 1e-12);
            testCase.verifyEqual(s4.strip_n_contacts, 64);
            testCase.verifyEqual(s5.strip_n_contacts, 128);
            testCase.verifyError(@() zef_strip_disc_lattice(5, 0.200), 'zef:DiscSite');
        end

        function disc128PreservesPlanarPitch(testCase)
            s = tests.unit.StripToolDiscTest.built(5);
            pts = tests.unit.StripToolDiscTest.pointsOf(s);
            radius = 0.674 / 2;
            testCase.verifyEqual(size(pts, 1), 128);
            testCase.verifyEqual(pts(1, :), [radius, 0, 0.040], 'AbsTol', 1e-10);
            angle2 = 0.250 / radius;
            testCase.verifyGreaterThan(abs(angle2 - pi / 4), 0.02);
            [x2, y2] = pol2cart(angle2, radius);
            testCase.verifyEqual(pts(2, :), [x2, y2, 0.040], 'AbsTol', 1e-10);
            [x8, y8] = pol2cart(7 * 0.250 / radius, radius);
            testCase.verifyEqual(pts(8, :), [x8, y8, 0.040], 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(9, :), [radius, 0, 0.240], 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(128, 3) - pts(1, 3), 15 * 0.200, 'AbsTol', 1e-10);
            tests.unit.StripToolDiscTest.verifyG128(testCase, pts, radius);
            arc = radius * atan2(sin(angle2), cos(angle2));
            testCase.verifyEqual(arc, 0.250, 'AbsTol', 1e-12);
            seam = 2 * pi * radius - 7 * 0.250;
            testCase.verifyGreaterThan(seam, 0.250);
            opposite = atan2(sin(7 * angle2 - 3 * angle2), cos(7 * angle2 - 3 * angle2));
            testCase.verifyGreaterThan(abs(opposite - pi), 0.05);
            testCase.verifyLessThan(abs(opposite - pi), 0.25);
        end

        function disc64IsTheShoresDiamondFilm(testCase)
            % Fig. 7: the two halves of a diamond are 0.230 mm apart.
            % Fig. 3A: 32 rows of 4, alternate rows turned 45 degrees,
            % every other diamond unwired. These numbers are not read
            % back from the lattice helper.
            s = tests.unit.StripToolDiscTest.built(4);
            pts = tests.unit.StripToolDiscTest.pointsOf(s);
            radius = 0.400;
            row_pitch = 0.230;
            tip = 0.040;
            testCase.verifyEqual(size(pts, 1), 64);
            testCase.verifyEqual(pts(1, :), [radius, 0, tip], 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(3, 1), -radius, 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(3, 2), 0, 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(3, 3), tip, 'AbsTol', 1e-10);
            [x5, y5] = pol2cart(pi / 4, radius);
            testCase.verifyEqual(pts(5, :), [x5, y5, tip + row_pitch], 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(9, :), [radius, 0, tip + 4 * row_pitch], 'AbsTol', 1e-10);
            testCase.verifyEqual(pts(64, 3) - pts(1, 3), 29 * row_pitch, 'AbsTol', 1e-10);
            g128 = tests.unit.StripToolDiscTest.pointsOf(tests.unit.StripToolDiscTest.built(5));
            testCase.verifyGreaterThan(norm(pts(1:64, :) - g128(1:64, :)), 0.1);

            for channel = 1:64
                diamond = floor((channel - 1) / 8);
                slot = mod(channel - 1, 8);
                sub = floor(slot / 4);
                column = mod(slot, 4);
                row = 4 * diamond + sub;
                angle = column * (pi / 2) + sub * (pi / 4);
                [x, y] = pol2cart(angle, radius);
                testCase.verifyEqual(pts(channel, :), [x, y, tip + row * row_pitch], 'AbsTol', 1e-10);
            end

            lattice = zef_strip_disc_lattice(4, radius);
            testCase.verifyEqual(lattice.n_physical, 128);
            testCase.verifyEqual(lattice.n_active, 64);
            testCase.verifyEqual(lattice.ring_pitch_mm, row_pitch);
            testCase.verifyEqual(lattice.channel(lattice.active_physical)', 1:64);
            rows = round((lattice.z_center - tip) / row_pitch);
            testCase.verifyEqual(unique(rows)', 0:31);
            inactive_rows = unique(rows(~lattice.active))';
            testCase.verifyEqual(inactive_rows, [2 3 6 7 10 11 14 15 18 19 22 23 26 27 30 31]);
            dz = diff(sort(unique(lattice.z_center)));
            testCase.verifyEqual(dz, row_pitch * ones(size(dz)), 'AbsTol', 1e-12);
        end

        function discDisksMatchLithographicArea(testCase)
            for model = 4:5
                s = tests.unit.StripToolDiscTest.baseStrip(model);
                s.strip_n_sectors = 16;
                s = zef_create_strip(s);
                lattice = zef_strip_disc_lattice(model, s.strip_radius);
                target = pi * (0.040) ^ 2;
                owned = zeros(size(s.triangles{1}, 1), 1);
                for physical = 1:lattice.n_physical
                    [tri_ind, center] = zef_strip_disc_patch(s, physical);
                    testCase.verifyGreaterThan(numel(tri_ind), 0);
                    faces = s.triangles{1}(tri_ind, :);
                    owned(tri_ind) = owned(tri_ind) + 1;
                    verts = s.points{1}(unique(faces(:)), :);
                    dtheta = atan2(sin(atan2(verts(:, 2), verts(:, 1)) - lattice.angle(physical)), ...
                        cos(atan2(verts(:, 2), verts(:, 1)) - lattice.angle(physical)));
                    unwrap = hypot(s.strip_radius * dtheta, verts(:, 3) - lattice.z_center(physical));
                    testCase.verifyLessThanOrEqual(max(unwrap), 0.040 + 1e-8);
                    area = tests.unit.StripToolDiscTest.patchArea(s.points{1}, faces);
                    testCase.verifyGreaterThan(area, 0.96 * target);
                    testCase.verifyLessThan(area, 1.04 * target);
                    testCase.verifyEqual(center(3), lattice.z_center(physical), 'AbsTol', 1e-12);
                end
                testCase.verifyLessThanOrEqual(max(owned), 1);
                testCase.verifyEqual(nnz(owned), sum(owned));
                radial = hypot(s.points{1}(:, 1), s.points{1}(:, 2));
                testCase.verifyEqual(max(abs(radial(radial > 1e-6) - s.strip_radius)), 0, 'AbsTol', 1e-8);
                testCase.verifyEqual(nnz(radial <= 1e-6), 2);
                [closed, outward] = tests.unit.StripToolDiscTest.meshState(s.points{1}, s.triangles{1});
                testCase.verifyTrue(closed);
                testCase.verifyTrue(outward);
            end
        end

        function activeChannelsDoNotClaimInactiveDisks(testCase)
            s = tests.unit.StripToolDiscTest.built(4);
            lattice = zef_strip_disc_lattice(4, s.strip_radius);
            active_faces = zeros(0, 1);
            for channel = 1:lattice.n_active
                [faces, ~, face_ind] = zef_get_strip_contacts(channel, s, struct(), 'model_geometry');
                testCase.verifyGreaterThan(size(faces, 1), 0);
                info = zef_get_strip_contacts(channel, s, struct(), 'model_geometry');
                [~, sensor_info] = zef_get_strip_contacts(channel, s, struct(), 'model_geometry');
                testCase.verifyEqual(sensor_info.electrode_representation, 'finite_area');
                testCase.verifyEqual(size(info, 2), 3);
                active_faces = [active_faces; face_ind(:)]; %#ok<AGROW>
            end
            inactive = find(~lattice.active, 1, 'first');
            [inactive_ind, ~] = zef_strip_disc_patch(s, inactive);
            testCase.verifyGreaterThan(numel(inactive_ind), 0);
            testCase.verifyEmpty(intersect(active_faces, inactive_ind));
        end

        function coarseMeshDoesNotInventADisk(testCase)
            s = tests.unit.StripToolDiscTest.built(4);
            zef = struct();
            zef.compartment_tags = {'lead'};
            zef.nodes = [0 0 0; 0 0 8; 4 0 4; 0 4 4];
            zef.surface_triangles = {[1 2 3; 1 2 4]};
            s.compartment_tag = {'lead'};
            [faces, sensor_info] = zef_get_strip_contacts(1, s, zef, 'mesh');
            testCase.verifyEqual(sensor_info.electrode_representation, 'point_unresolved');
            testCase.verifySize(faces, [1, 3]);
            testCase.verifyEqual(faces(3), 0);
            testCase.verifyGreaterThan(faces(1), 0);
            testCase.verifyEqual(faces(2), 1);
        end

        function discContactsFollowLeadFrame(testCase)
            s = tests.unit.StripToolDiscTest.baseStrip(5);
            s.strip_angle = 0.6;
            s.tip_point = [-8; -10; -18];
            s.orientation_axis = {[1; 0; 2], [0; 0; 1]};
            s.encapsulation_shift = [0; 0; -10];
            s = zef_create_strip(s);
            s.encapsulation_on = 1;
            radius = 0.674 / 2;
            angle = 0.250 / radius;
            z_center = 0.040;
            [x_local, y_local] = pol2cart(angle, radius);
            world_center = zef_strip_coordinate_transform(s, 'forward', [x_local, y_local, z_center]);
            point = zef_get_strip_contacts(2, s, struct(), 'points');
            testCase.verifyEqual(point, world_center, 'AbsTol', 1e-8);
            rotated = point;
            s.strip_angle = s.strip_angle + pi / 2;
            turned = zef_get_strip_contacts(2, s, struct(), 'points');
            testCase.verifyGreaterThan(norm(turned - rotated), 0.1);
            s.strip_angle = 0.6;

            world = zef_strip_coordinate_transform(s, 'forward');
            [local_faces, ~, local_ind] = zef_get_strip_contacts(2, s, struct(), 'model_geometry');
            zef = struct();
            zef.compartment_tags = {'lead'};
            zef.reuna_p = world(1);
            zef.reuna_t = s.triangles(1);
            s.compartment_tag = {'lead'};
            [world_faces, ~, world_ind] = zef_get_strip_contacts(2, s, zef, 'geometry');
            testCase.verifyEqual(world_ind, local_ind);
            testCase.verifyEqual(world_faces, local_faces);
        end

        function savedMeshReloadsTheSameSites(testCase)
            s = tests.unit.StripToolDiscTest.built(4);
            file = [tempname, '.mat'];
            testCase.addTeardown(@() local_delete_file(file));
            save(file, 's');
            loaded = load(file);
            testCase.verifyEqual(loaded.s.points{1}, s.points{1}, 'AbsTol', 1e-12);
            testCase.verifyEqual(loaded.s.triangles{1}, s.triangles{1});
            fresh = tests.unit.StripToolDiscTest.built(4);
            testCase.verifyEqual(fresh.points{1}, s.points{1}, 'AbsTol', 1e-12);
            reloaded_pts = tests.unit.StripToolDiscTest.pointsOf(loaded.s);
            testCase.verifyEqual(reloaded_pts(3, :), [-0.400, 0, 0.040], 'AbsTol', 1e-10);
        end

        function legacyShaftUsesTheCylinderGenerator(testCase)
            for model = 1:3
                s = tests.unit.StripToolDiscTest.built(model);
                shifted = s.points{1};
                shifted(:, 3) = shifted(:, 3) - s.strip_length / 2;
                [triangles, generated] = zef_simple_cylinder_generator( ...
                    s.strip_radius, s.strip_n_sectors, s.strip_length);
                testCase.verifyEqual(s.triangles{1}, triangles);
                testCase.verifyEqual(shifted, generated, 'AbsTol', 1e-12);
                faces = zef_get_strip_contacts(1, s, struct(), 'model_geometry');
                testCase.verifyGreaterThan(size(faces, 1), 0);
            end
        end

        function plotPaintsPhysicalAndActiveContacts(testCase)
            old_vis = get(0, 'DefaultFigureVisible');
            cleaner = onCleanup(@() set(0, 'DefaultFigureVisible', old_vis)); %#ok<NASGU>
            set(0, 'DefaultFigureVisible', 'off');
            try
                fig = figure('Visible', 'off');
            catch ME
                if tests.unit.StripToolDiscTest.displayMissing(ME)
                    testCase.assumeFail(['No display available for the strip plot. ' ME.message]);
                end
                rethrow(ME);
            end
            testCase.addTeardown(@() local_close(fig));
            ax = axes(fig);
            s = tests.unit.StripToolDiscTest.baseStrip(4);
            s.encapsulation_on = 1;
            s.encapsulation_shift = [0; 0; -10];
            zef = struct();
            zef.h_axes1 = ax;
            zef.current_sensors = 's';
            zef.strip_tool = struct('current_strip', 1);
            zef.s_strip_cell = {s};
            lastwarn(''); %#ok<LWLAST>
            zef_strip_tool_plot(zef);
            [warn_msg, ~] = lastwarn;
            testCase.verifyEmpty(warn_msg);
            active = findobj(ax, 'Tag', 'additional: strip contact');
            inactive = findobj(ax, 'Tag', 'additional: strip contact inactive');
            body = findobj(ax, 'Tag', 'additional: strip');
            sheath = findobj(ax, 'Tag', 'additional: strip encapsulation');
            testCase.verifyEqual(numel(active), 64);
            testCase.verifyEqual(numel(inactive), 64);
            testCase.verifyEqual(numel(body), 1);
            testCase.verifyEqual(numel(sheath), 1);
            testCase.verifyEqual(active(1).FaceColor, [0 0 0]);
            testCase.verifyEqual(inactive(1).FaceColor, [0.55 0.55 0.55]);
            for handle = reshape([active(:); inactive(:)], 1, [])
                testCase.verifyGreaterThan(size(handle.Faces, 1), 0);
            end
        end

        function shortShaftOmitsDisksPastTheTip(testCase)
            s = tests.unit.StripToolDiscTest.baseStrip(5);
            s.strip_length = 1;
            s.encapsulation_length = 1;
            s = zef_create_strip(s);
            n_hit = 0;
            for contact = 1:s.strip_n_contacts
                faces = zef_get_strip_contacts(contact, s, struct(), 'model_geometry');
                [~, z_center] = zef_strip_disc_site(contact, 5, s.strip_radius);
                on_shaft = z_center - 0.040 >= -1e-9 && z_center + 0.040 <= s.strip_length + 1e-9;
                if on_shaft
                    testCase.verifyGreaterThan(size(faces, 1), 0);
                    n_hit = n_hit + 1;
                else
                    testCase.verifyEmpty(faces);
                end
            end
            testCase.verifyEqual(n_hit, 40);
            point = zef_get_strip_contacts(128, s, struct(), 'points');
            testCase.verifyEqual(point(3), 0.040 + 15 * 0.200, 'AbsTol', 1e-10);
        end

        function everyActiveDiskEntersTheElectrodeMatrix(testCase)
            for model = [4 5]
                s = tests.unit.StripToolDiscTest.built(model);
                n = s.strip_n_contacts;
                rows = zeros(0, 4);
                for contact = 1:n
                    faces = zef_get_strip_contacts(contact, s, struct(), 'model_geometry');
                    rows = [rows; contact * ones(size(faces, 1), 1), faces]; %#ok<AGROW>
                end
                testCase.verifyEqual(unique(rows(:, 1))', 1:n);
                if model == 4
                    testCase.verifyEqual(n, 64);
                else
                    testCase.verifyEqual(n, 128);
                end
                impedance = 1000 * ones(n, 1);
                nodes = s.points{1};
                [~, B, C] = zef_build_electrodes(nodes, 'CEM', impedance, 0, rows, sparse(size(nodes, 1), size(nodes, 1)));
                testCase.verifySize(C, [n, n]);
                testCase.verifyEqual(full(diag(C)), 1 ./ impedance, 'AbsTol', 1e-12);
                for contact = 1:n
                    used = unique(rows(rows(:, 1) == contact, 2:4));
                    center = zef_get_strip_contacts(contact, s, struct(), 'points');
                    dtheta = atan2(sin(atan2(nodes(used, 2), nodes(used, 1)) - atan2(center(2), center(1))), ...
                        cos(atan2(nodes(used, 2), nodes(used, 1)) - atan2(center(2), center(1))));
                    unwrap = hypot(s.strip_radius * dtheta, nodes(used, 3) - center(3));
                    testCase.verifyLessThanOrEqual(max(unwrap), 0.040 + 1e-8);
                    testCase.verifyGreaterThan(nnz(B(:, contact)), 0);
                end
            end
        end

        function attachedChannelsAreThoseDisks(testCase)
            % The EEG script attaches through zef_cem_electrode and
            % zef_attach_sensors_volume. Each get_function names one
            % active channel. Inactive sites are not sensors.
            for model = [4 5]
                s = tests.unit.StripToolDiscTest.built(model);
                [attached, zef, sensors] = tests.unit.StripToolDiscTest.attachShaft(s);
                n = s.strip_n_contacts;
                testCase.verifyEqual(unique(attached(:, 1))', 1:n);
                aux = zef_lead_field_sensors_aux(1, sensors, attached);
                testCase.verifyEqual(aux, attached);
                lattice = zef_strip_disc_lattice(model, s.strip_radius);
                owned = zeros(size(s.triangles{1}, 1), 1);
                for channel = 1:n
                    rows = attached(attached(:, 1) == channel, 2:4);
                    faces = zef_get_strip_contacts(channel, s, struct(), 'model_geometry');
                    testCase.verifyEqual(sortrows(rows), sortrows(faces));
                    [~, sensor_info] = zef_get_strip_contacts(channel, zef.s_strip_cell{1}, zef, 'mesh');
                    testCase.verifyEqual(sensor_info.electrode_representation, 'finite_area');
                    physical = lattice.active_physical(channel);
                    [disk_faces, ~] = zef_strip_disc_patch(s, physical);
                    testCase.verifyEqual(sort(disk_faces), sort(unique( ...
                        find(sum(ismember(s.triangles{1}, unique(rows(:))), 2) == 3))));
                    owned(disk_faces) = owned(disk_faces) + 1;
                end
                testCase.verifyLessThanOrEqual(max(owned), 1);
                inactive = find(~lattice.active);
                for index = reshape(inactive, 1, [])
                    [inactive_faces, ~] = zef_strip_disc_patch(s, index);
                    testCase.verifyEmpty(intersect(find(owned), inactive_faces));
                end

                opposite = 3;
                if model == 5
                    opposite = 5;
                end
                zef.s_get_functions{1} = sprintf( ...
                    ['zef_get_strip_contacts(%d, project_struct.s_strip_cell{1}, ' ...
                    'project_struct, domain_type);'], opposite);
                moved = zef_attach_sensors_volume(zef, sensors, 'mesh');
                testCase.verifyEqual( ...
                    sortrows(moved(moved(:, 1) == 1, 2:4)), ...
                    sortrows(attached(attached(:, 1) == opposite, 2:4)));
                testCase.verifyEqual( ...
                    sortrows(moved(moved(:, 1) == opposite, 2:4)), ...
                    sortrows(attached(attached(:, 1) == opposite, 2:4)));
                testCase.verifyEqual( ...
                    sortrows(moved(moved(:, 1) == 2, 2:4)), ...
                    sortrows(attached(attached(:, 1) == 2, 2:4)));
            end
        end

        function insulatingShaftChangesTheFacingLeadfield(testCase)
            % Finite-area CEM on the lithographic disks. The volume is a
            % Delaunay mesh that contains those disk vertices, because
            % the Cartesian Zeffiro lattice does not resolve 0.080 mm.
            % Electrode 1 faces +x, electrode 2 is the far side of the
            % same row, electrode 3 is a distant point reference.
            % DiSC-64 channel 3 is 180 degrees from channel 1. DiSC-128
            % channel 5 is four film pitches away, 170 degrees on the
            % 0.674 mm shaft.
            pairs = [4, 3; 5, 5];
            for pair = 1:size(pairs, 1)
                model = pairs(pair, 1);
                opposite = pairs(pair, 2);
                s = tests.unit.StripToolDiscTest.baseStrip(model);
                s.strip_length = 4;
                s.strip_n_sectors = 12;
                s = zef_create_strip(s);
                [attached, zef_attach, sensors] = tests.unit.StripToolDiscTest.attachShaft(s);
                zef_attach.s_get_functions{1} = sprintf( ...
                    ['zef_get_strip_contacts(%d, project_struct.s_strip_cell{1}, ' ...
                    'project_struct, domain_type);'], opposite);
                moved_attached = zef_attach_sensors_volume(zef_attach, sensors, 'mesh');
                [nodes, tetra, ~, ~] = tests.unit.StripToolDiscTest.discVolume(s, 1, opposite);
                facing_rows = tests.unit.StripToolDiscTest.remapRows( ...
                    1, attached(attached(:, 1) == 1, 2:4), s.points{1}, nodes);
                opposite_rows = tests.unit.StripToolDiscTest.remapRows( ...
                    2, attached(attached(:, 1) == opposite, 2:4), s.points{1}, nodes);
                moved_rows = tests.unit.StripToolDiscTest.remapRows( ...
                    1, moved_attached(moved_attached(:, 1) == 1, 2:4), s.points{1}, nodes);
                testCase.verifyGreaterThan(min(facing_rows(:, 4)), 0);
                testCase.verifyGreaterThan(min(opposite_rows(:, 4)), 0);
                tissue = 0.33;
                insulated = tests.unit.StripToolDiscTest.conductivity( ...
                    nodes, tetra, s.strip_radius, s.strip_length, 1e-4, tissue);
                conducting = tissue * ones(size(tetra, 1), 1);
                source = tests.unit.StripToolDiscTest.sourceNear( ...
                    nodes, tetra, [s.strip_radius + 0.8, 0, 0.040]);
                L_ins = tests.unit.StripToolDiscTest.leadfield( ...
                    nodes, tetra, insulated, facing_rows, opposite_rows, source);
                L_cond = tests.unit.StripToolDiscTest.leadfield( ...
                    nodes, tetra, conducting, facing_rows, opposite_rows, source);
                testCase.verifySize(L_ins, [3, 3]);
                testCase.verifyTrue(all(isfinite(L_ins), 'all'));
                testCase.verifyTrue(all(isfinite(L_cond), 'all'));
                scale = max(1e-12, max(abs(L_ins), [], 'all'));
                testCase.verifyLessThan(max(abs(sum(L_ins, 1))) / scale, 1e-6);
                contrast = @(L) abs(L(1, 1) - L(2, 1));
                testCase.verifyGreaterThan(contrast(L_ins) / max(contrast(L_cond), 1e-15), 1.2);

                depth = L_ins(1:2, :);
                data = depth(:, 1);
                estimate = pinv(depth) * data;
                fitted = depth * estimate;
                testCase.verifyLessThan(norm(fitted - data), 1e-6 * max(1, norm(data)));
                L_moved = tests.unit.StripToolDiscTest.leadfield( ...
                    nodes, tetra, insulated, moved_rows, opposite_rows, source);
                estimate_moved = pinv(L_moved(1:2, :)) * data;
                testCase.verifyGreaterThan(norm(estimate_moved - estimate), 0);
            end
        end

        function popupNamesTheTwoDesigns(testCase)
            old_vis = get(0, 'DefaultFigureVisible');
            cleaner = onCleanup(@() set(0, 'DefaultFigureVisible', old_vis)); %#ok<NASGU>
            try
                set(0, 'DefaultFigureVisible', 'off');
                zef = struct('strip_tool', struct());
                zef = zef_strip_tool_window(zef);
            catch ME
                if tests.unit.StripToolDiscTest.displayMissing(ME)
                    testCase.assumeFail(['No display available for the Strip tool figure; popup String assertion skipped. ' ME.message]);
                end
                rethrow(ME);
            end
            fig = zef.strip_tool.h_window;
            testCase.addTeardown(@() local_close(fig));
            labels = zef.strip_tool.h_strip_model.String;
            testCase.verifyEqual(labels(:)', {'Omnidirectional 4','Directional 8','Directional 40', ...
                'DiSC 64 (Shores 2026)','DiSC 128 (Abrego G-128)'});

            zef.current_sensors = 's';
            zef.strip_tool.current_strip = 1;
            zef.strip_tool.strip_current_id = 1;
            zef.s_strip_cell = { ...
                struct('strip_id', 1, 'strip_tag', 'a', 'strip_model', 4, ...
                    'strip_status', 'Tentative', 'encapsulation_on', 0), ...
                struct('strip_id', 2, 'strip_tag', 'b', 'strip_model', 5, ...
                    'strip_status', 'Tentative', 'encapsulation_on', 0)};
            zef.strip_tool.h_strip_model.Value = 1;
            zef = zef_strip_tool_init(zef);
            testCase.verifyEqual(zef.strip_tool.h_strip_model.Value, 4);
            zef = zef_strip_tool_update(zef);
            names = zef.strip_tool.h_strip_list.UserData.Names;
            testCase.verifyTrue(contains(names{1}, 'Shores 2026'));
            testCase.verifyTrue(contains(names{2}, 'Abrego G-128'));
            testCase.verifyEqual(zef.s_strip_cell{1}.strip_model, 4);
            testCase.verifyEqual(zef.s_strip_cell{2}.strip_model, 5);
        end
    end

    methods (Static, Access = private)
        function s = baseStrip(model)
            s = struct();
            s.strip_model = model;
            s.orientation_axis = {[0; 0; 1], [0; 0; 1]};
            s.tip_point = [0; 0; 0];
            s.strip_angle = 0;
            s.strip_length = 10;
            s.encapsulation_length = 10;
            s.encapsulation_thickness = 0.5;
            s.encapsulation_on = 0;
            s.strip_n_sectors = 20;
            s.strip_id = 1;
        end

        function s = parameters(model)
            s = zef_get_strip_parameters(tests.unit.StripToolDiscTest.baseStrip(model));
        end

        function s = built(model)
            s = zef_create_strip(tests.unit.StripToolDiscTest.baseStrip(model));
        end

        function pts = pointsOf(s)
            n = s.strip_n_contacts;
            pts = zeros(n, 3);
            for i = 1:n
                pts(i, :) = zef_get_strip_contacts(i, s, struct(), 'points');
            end
        end

        function verifyG128(testCase, pts, radius)
            for index = 1:size(pts, 1)
                row = ceil(index / 8) - 1;
                column = mod(index - 1, 8);
                angle = column * 0.250 / radius;
                [x, y] = pol2cart(angle, radius);
                z = 0.040 + row * 0.200;
                testCase.verifyEqual(pts(index, :), [x, y, z], 'AbsTol', 1e-10);
            end
            dmin = inf;
            for index = 1:size(pts, 1) - 1
                delta = pts(index + 1:end, :) - pts(index, :);
                dmin = min(dmin, min(sqrt(sum(delta .^ 2, 2))));
            end
            testCase.verifyGreaterThan(dmin, 0.080);
        end

        function [attached, zef, sensors] = attachShaft(s)
            zef = struct();
            zef.imaging_method = 1;
            zef.current_sensors = 's';
            zef.use_depth_electrodes = 1;
            zef.compartment_tags = {'lead'};
            zef.reuna_type = {1};
            zef.reuna_p = s.points(1);
            zef.reuna_t = s.triangles(1);
            zef.nodes = s.points{1};
            zef.surface_triangles = s.triangles(1);
            % Outer radius 0 is the value Add contacts stores. Attachment
            % still prepares the buried-contact tetra test before it
            % honours get_functions, so one tetra has to exist.
            zef.tetra = [1 2 3 4];
            n = s.strip_n_contacts;
            zef.s_points = zeros(n, 3);
            for channel = 1:n
                zef.s_points(channel, :) = zef_get_strip_contacts(channel, s, struct(), 'points');
            end
            s.compartment_tag = {'lead'};
            zef.s_electrode_inner_radius = zeros(n, 1);
            zef.s_electrode_outer_radius = zeros(n, 1);
            zef.s_electrode_impedance = 1000 * ones(n, 1);
            zef.s_get_functions = arrayfun(@(channel) sprintf( ...
                ['zef_get_strip_contacts(%d, project_struct.s_strip_cell{1}, ' ...
                'project_struct, domain_type);'], channel), 1:n, 'UniformOutput', false);
            zef.s_strip_cell = {s};
            sensors = zef_cem_electrode(zef, zef.s_points);
            attached = zef_attach_sensors_volume(zef, sensors, 'mesh');
        end

        function [nodes, tetra, facing_rows, opposite_rows] = discVolume(s, facing, opposite)
            cloud = s.points{1};
            [x, y, z] = ndgrid(-2:0.5:2, -2:0.5:2, -0.5:0.5:s.strip_length + 0.5);
            cloud = [cloud; x(:), y(:), z(:)];
            cloud = unique(round(cloud, 8), 'rows');
            dt = delaunayTriangulation(cloud);
            tetra = dt.ConnectivityList;
            nodes = dt.Points;
            volume = abs(dot(nodes(tetra(:, 1), :) - nodes(tetra(:, 4), :), ...
                cross(nodes(tetra(:, 2), :) - nodes(tetra(:, 4), :), ...
                nodes(tetra(:, 3), :) - nodes(tetra(:, 4), :), 2), 2)) / 6;
            tetra = tetra(volume > 1e-8, :);
            facing_faces = zef_get_strip_contacts(facing, s, struct(), 'model_geometry');
            opposite_faces = zef_get_strip_contacts(opposite, s, struct(), 'model_geometry');
            facing_rows = tests.unit.StripToolDiscTest.remapRows(1, facing_faces, s.points{1}, nodes);
            opposite_rows = tests.unit.StripToolDiscTest.remapRows(2, opposite_faces, s.points{1}, nodes);
        end

        function rows = remapRows(electrode, faces, source_nodes, nodes)
            used = unique(faces(:));
            [~, map] = ismember(round(source_nodes(used, :), 8), round(nodes, 8), 'rows');
            if any(map == 0)
                error('zef:DiscTest', 'A contact vertex is missing from the volume mesh.');
            end
            lookup = zeros(size(source_nodes, 1), 1);
            lookup(used) = map;
            rows = [electrode * ones(size(faces, 1), 1), lookup(faces)];
        end

        function sigma = conductivity(nodes, tetra, radius, length_mm, shaft, tissue)
            centroid = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) ...
                + nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;
            inside = hypot(centroid(:, 1), centroid(:, 2)) < radius - 0.02 ...
                & centroid(:, 3) > 0.05 & centroid(:, 3) < length_mm - 0.05;
            sigma = tissue * ones(size(tetra, 1), 1);
            sigma(inside) = shaft;
        end

        function source = sourceNear(nodes, tetra, target)
            centroid = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) ...
                + nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;
            outside = hypot(centroid(:, 1), centroid(:, 2)) > 0.5;
            centroid(~outside, :) = inf;
            [~, source] = min(sum((centroid - target) .^ 2, 2));
        end

        function L = leadfield(nodes_mm, tetra, sigma, facing_rows, opposite_rows, source)
            nodes = nodes_mm / 1000;
            far = find(nodes_mm(:, 1) < -1.5 & nodes_mm(:, 3) > 2, 1, 'first');
            if isempty(far)
                error('zef:DiscTest', 'The volume mesh has no distant reference node.');
            end
            rows = [facing_rows; opposite_rows; 3, far, 1, 0];
            zef = struct();
            zef.source_model = core.types.ZefSourceModel.Whitney;
            zef.use_gpu = 0;
            zef.gpu_count = 0;
            zef.parallel_processes = 1;
            zef.processes_per_core = 1;
            zef.parallel_vectors = 1;
            lf_param = struct( ...
                "direction_mode", "cartesian", ...
                "precond", "ssor", ...
                "pcg_tol", 1e-6, ...
                "maxit", 800, ...
                "impedances", 1000 * ones(3, 1));
            source = source(:);
            brain = (1:size(tetra, 1))';
            L = zef_lead_field_eeg_fem( ...
                zef, nodes, tetra, sigma, rows, [], "pbo", ...
                brain, source, lf_param);
        end

        function area = patchArea(points, faces)
            edge_1 = points(faces(:, 2), :) - points(faces(:, 1), :);
            edge_2 = points(faces(:, 3), :) - points(faces(:, 1), :);
            normal = cross(edge_1, edge_2, 2);
            area = 0.5 * sum(sqrt(sum(normal .^ 2, 2)));
        end

        function [closed, outward] = meshState(points, triangles)
            edges = [triangles(:, [1 2]); triangles(:, [2 3]); triangles(:, [3 1])];
            [~, ~, directed] = unique(edges, 'rows');
            [~, ~, undirected] = unique(sort(edges, 2), 'rows');
            closed = all(accumarray(directed, 1) == 1) && all(accumarray(undirected, 1) == 2);
            volume = sum(dot(points(triangles(:, 1), :), ...
                cross(points(triangles(:, 2), :), points(triangles(:, 3), :), 2), 2)) / 6;
            outward = volume > 0;
        end

        function tf = displayMissing(ME)
            id = lower(char(string(ME.identifier)));
            msg = lower(char(string(ME.message)));
            tf = contains(id, 'display') || contains(msg, 'display') || contains(msg, 'no java');
        end
    end
end

function local_close(fig)
if ~isempty(fig) && isgraphics(fig) && isvalid(fig)
    delete(fig);
end
end

function local_delete_file(file)
if isfile(file)
    delete(file);
end
end
