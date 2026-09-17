classdef SensorTableSyncTest < matlab.unittest.TestCase
%SENSORTABLESYNCTEST  Sensor-set name/visibility survive table rebuild and zef_update.

    properties
        Figures
    end

    methods (TestMethodTeardown)
        function closeFigures(testCase)
            figs = testCase.Figures;
            testCase.Figures = [];
            if ~isempty(figs)
                for i = 1:numel(figs)
                    try
                        if isgraphics(figs(i)) && isvalid(figs(i))
                            delete(figs(i));
                        end
                    catch
                    end
                end
            end
            try
                wb = findall(groot, 'Tag', 'progress_bar');
                delete(wb);
            catch
            end
        end
    end

    methods (Test)
        function buildTableWritesEightColumnsIncludingNamesVisible(testCase)
            zef = i_two_set_session();
            zef = i_attach_sensors_table(testCase, zef);
            zef = zef_build_sensors_table(zef);
            data = zef.h_sensors_table.Data;
            testCase.verifyEqual(size(data, 2), 8);
            testCase.verifyEqual(size(data, 1), 2);
            testCase.verifyEqual(char(string(data{1,2})), 'Electrodes');
            testCase.verifyEqual(double(data{1,5}), 1);
            testCase.verifyEqual(char(string(data{2,2})), 'Sensors 1');
            testCase.verifyEqual(double(data{2,5}), 0);
        end

        function staleSevenColumnTableDoesNotClobberImportedSet(testCase)
            zef = i_two_set_session();
            zef = i_attach_update_handles(testCase, zef);
            % Leftover default row from before zef_add_sensors rebuilt the table.
            zef.h_sensors_table.Data = {1, 'Sensors 1', 'EEG', 1, 0, true, false};
            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            testCase.verifyEqual(numel(zef.sensor_tags), 2);
            testCase.verifyEqual(size(zef.h_sensors_table.Data, 2), 8);
            testCase.verifyEqual(char(string(zef.h_sensors_table.Data{1,2})), 'Electrodes');
        end

        function importNameAndVisibleSurviveRebuildAndUpdate(testCase)
            zef = i_default_s_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            zef_add_sensors;
            zef.s2_name = 'Electrodes';
            zef.s2_visible = 1;
            zef.s2_on = 1;
            zef.s2_points = [0 0 0; 1 0 0; 0 1 0];
            zef.current_sensors = 's2';
            zef = zef_build_sensors_table(zef);
            zef.h_sensors_table.Data = zef.h_sensors_table.Data(:, 1:7);
            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 3);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
            testCase.verifyEqual(string(names{2}), "Electrodes 2");
            testCase.verifyEqual(string(names{3}), "Electrodes 3");
        end

        function extraIndexComesFromDefaultSetNameNotDisplayFormatting(testCase)
            zef = struct();
            zef.current_sensors = 's2';
            zef.s2_points = rand(4, 3);
            zef.s2_name = 'Sensors 1';
            zef.s2_name_list = {'1', '2', '3', '4'};
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 4);
            testCase.verifyEqual(string(names{1}), "Sensors 1 1");
            zef.s2_name = 'Electrodes';
            names = zef_sensor_list_items(zef);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
        end

        function openProjectStaleStartupRowDoesNotClobberElectrodes(testCase)
            % zef_start fills the sensors table with the empty default set.
            % open_project then replaces sensor_tags with the loaded tag
            % without rebuilding the table. zef_create_finite_element_mesh
            % used to call zef_update and copy "Sensors 1"/Visible=0 onto s2.
            zef = i_default_s_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            testCase.verifyEqual(char(string(zef.h_sensors_table.Data{1,2})), 'Sensors 1');
            testCase.verifyEqual(logical(zef.h_sensors_table.Data{1,7}), false);

            zef = zef_create_sensors(zef, 's2');
            zef.s2_name = 'Electrodes';
            zef.s2_visible = 1;
            zef.s2_on = 1;
            zef.s2_points = load(i_electrodes_dat());
            zef.s2_name_list = arrayfun(@(k) num2str(k), 1:size(zef.s2_points, 1), 'UniformOutput', false);
            zef.sensor_tags = {'s2'};
            zef.current_sensors = 's2';
            % Same flag zef_merge_project_data sets: live table is leftover.
            zef.sensors_table_synced = false;

            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            testCase.verifyEqual(char(string(zef.current_sensors)), 's2');
            testCase.verifyGreaterThan(nnz(zef.s2_visible_list), 0);
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 72);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
            testCase.verifyEqual(string(names{72}), "Electrodes 72");
            testCase.verifyEqual(char(string(zef.h_sensors_table.Data{1,2})), 'Electrodes');
            testCase.verifyEqual(logical(zef.h_sensors_table.Data{1,5}), true);
        end

        function mergeProjectDataMarksSensorsTableUnsynced(testCase)
            zef = i_default_s_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            testCase.verifyTrue(logical(zef.sensors_table_synced));

            zef_data = struct();
            zef_data.sensor_tags = {'s2'};
            zef_data.current_sensors = 's2';
            zef_data.s2_name = 'Electrodes';
            zef_data.s2_visible = 1;
            zef_data.s2_on = 1;
            zef_data.s2_points = load(i_electrodes_dat());
            zef_data.s2_name_list = arrayfun(@(k) num2str(k), 1:72, 'UniformOutput', false);
            zef_data.s2_imaging_method_name = 'EEG';
            zef_data.s2_names_visible = 0;
            zef_data.s2_visible_list = ones(72, 1);
            zef_data.mesh_resolution = 1;
            zef_data.refinement_on = 1;
            zef_data.max_surface_face_count = Inf;

            zef = zef_merge_project_data(zef, zef_data);
            testCase.verifyFalse(logical(zef.sensors_table_synced));
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(char(string(zef.h_sensors_table.Data{1,2})), 'Sensors 1');

            zef = zef_create_sensors(zef, 's2');
            zef.mesh_resolution = 1;
            zef.refinement_on = 1;
            zef.max_surface_face_count = Inf;
            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            testCase.verifyGreaterThan(nnz(zef.s2_visible_list), 0);
            testCase.verifyEqual(zef.mesh_resolution, 1);
            testCase.verifyEqual(double(zef.refinement_on), 1);
            testCase.verifyEqual(zef.max_surface_face_count, Inf);
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 72);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
        end

        function createFemTailRebuildPreservesElectrodesAndMeshParams(testCase)
            zef = i_default_s_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            zef = zef_create_sensors(zef, 's2');
            zef.s2_name = 'Electrodes';
            zef.s2_visible = 1;
            zef.s2_on = 1;
            zef.s2_points = load(i_electrodes_dat());
            zef.s2_name_list = arrayfun(@(k) num2str(k), 1:size(zef.s2_points, 1), 'UniformOutput', false);
            zef.sensor_tags = {'s2'};
            zef.current_sensors = 's2';
            zef.sensors_table_synced = false;
            zef.mesh_resolution = 1;
            zef.refinement_on = 1;
            zef.max_surface_face_count = Inf;
            zef = i_attach_mesh_tool(testCase, zef, 3, false, 1);

            zef = zef_build_sensors_table(zef);
            zef = zef_apply_mesh_tool_values(zef);
            zef = zef_update(zef);

            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            testCase.verifyEqual(zef.mesh_resolution, 1);
            testCase.verifyEqual(double(zef.refinement_on), 1);
            testCase.verifyEqual(zef.max_surface_face_count, Inf);
            testCase.verifyEqual(zef.h_edit65.Value, 1);
            testCase.verifyEqual(logical(zef.h_refinement_on.Value), true);
            testCase.verifyEqual(zef.h_max_surface_face_count.Value, Inf);
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 72);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
        end

        function sevenColumnMatchingRowsStillRebuildFromZef(testCase)
            zef = i_two_set_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            zef.h_sensors_table.Data = { ...
                1, 'Sensors 1', 'EEG', true, false, true, true, false; ...
                2, 'Sensors 1', 'EEG', true, false, true, false, false};
            zef.h_sensors_table.Data = zef.h_sensors_table.Data(:, 1:7);
            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            testCase.verifyEqual(size(zef.h_sensors_table.Data, 2), 8);
        end

        function eightColumnUserEditIsAuthoritative(testCase)
            zef = i_two_set_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            zef.h_sensors_table.Data{1,2} = 'Renamed cap';
            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Renamed cap');
        end

        function importElectrodesThenStaleTableKeepsNameAndVisibility(testCase)
            zef = i_default_s_session();
            zef = i_attach_update_handles(testCase, zef);
            zef = zef_build_sensors_table(zef);
            tmp = tempname;
            mkdir(tmp);
            cleaner = onCleanup(@() rmdir(tmp, 's'));
            copyfile(i_electrodes_dat(), fullfile(tmp, 'electrodes.dat'));
            fid = fopen(fullfile(tmp, 'import.zef'), 'w');
            testCase.assertGreaterThan(fid, 0);
            fprintf(fid, ['type,sensors,name,Electrodes,filename,electrodes.dat,' ...
                'filetype,points,modality,EEG\n']);
            fclose(fid);
            zef.use_display = false;
            zef.program_path = i_repo_root();
            zef.profile_name = 'multicompartment_head';
            zef = zef_import_segmentation(zef, 'import.zef', tmp);
            zef.h_sensors_table.Data = {1, 'Sensors 1', 'EEG', 1, 0, true, false};
            zef = zef_update(zef);
            testCase.verifyEqual(char(string(zef.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(zef.s2_visible), 1);
            testCase.verifyEqual(char(string(zef.current_sensors)), 's2');
            testCase.verifyEqual(size(zef.s2_points, 1), 72);
            testCase.verifyEqual(zef.s2_points(1,:), [-22.7323 74.1356 35.6314], 'AbsTol', 1e-4);
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 72);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
            testCase.verifyEqual(string(names{2}), "Electrodes 2");
            testCase.verifyEqual(string(names{72}), "Electrodes 72");
            out = struct();
            out.s2_name = zef.s2_name;
            out.s2_visible = zef.s2_visible;
            out.s2_points = zef.s2_points;
            out.current_sensors = zef.current_sensors;
            out.s2_name_list = zef.s2_name_list;
            save(fullfile(tmp, 'sensors_roundtrip.mat'), '-struct', 'out');
            loaded = load(fullfile(tmp, 'sensors_roundtrip.mat'));
            testCase.verifyEqual(char(string(loaded.s2_name)), 'Electrodes');
            testCase.verifyEqual(double(loaded.s2_visible), 1);
            testCase.verifyEqual(size(loaded.s2_points, 1), 72);
            names = zef_sensor_list_items(loaded);
            testCase.verifyEqual(string(names{1}), "Electrodes 1");
        end
    end
end

function zef = i_default_s_session()
zef = struct();
zef.sensor_tags = {};
zef.compartment_tags = {};
zef.imaging_method_cell = {'EEG', 'MEG magnetometer', 'MEG gradiometers'};
zef.imaging_method = 1;
zef.parameter_profile = cell(0, 8);
zef.profile_name = 'multicompartment_head';
zef.program_path = i_repo_root();
zef.use_display = false;
zef.project_tag = '';
zef.project_notes = {''};
zef.lock_on = 0;
zef.lock_sensor_sets_on = 0;
zef.lock_sensor_names_on = 0;
zef.lock_transforms_on = 0;
zef = zef_create_sensors(zef, 's');
end

function zef = i_two_set_session()
zef = i_default_s_session();
zef = zef_create_sensors(zef, 's2');
zef.s2_name = 'Electrodes';
zef.s2_visible = 1;
zef.s2_on = 1;
zef.s2_points = [0 0 90; 10 0 90; -10 0 90];
zef.s2_name_list = {'1', '2', '3'};
zef.current_sensors = 's2';
end

function zef = i_attach_sensors_table(testCase, zef)
fig = uifigure('Visible', 'off');
testCase.Figures = [testCase.Figures, fig];
zef.h_sensors_table = uitable(fig);
zef.h_sensors_table.ColumnName = {'ID'; 'Name'; 'Modality'; 'On'; 'Visible'; 'Tags'; 'Points'; 'Directions'};
zef.h_sensors_table.ColumnFormat = {'numeric','char','char','logical','logical','logical','logical','logical'};
zef.h_sensors_table.CellEditCallback = '';
end

function zef = i_attach_update_handles(testCase, zef)
zef = i_attach_sensors_table(testCase, zef);
fig = zef.h_sensors_table.Parent;
zef.h_zeffiro_window_main = fig;
zef.h_compartment_table = uitable(fig);
zef.h_compartment_table.ColumnName = {'ID', 'On'};
zef.h_compartment_table.ColumnEditable = [true true];
zef.h_compartment_table.Data = {};
zef.h_sensors_name_table = uitable(fig);
zef.h_sensors_name_table.ColumnName = {'ID'; 'Tag'; 'Visible'};
zef.h_sensors_name_table.ColumnEditable = [true true true];
zef.h_sensors_name_table.Data = {};
zef.h_parameters_table = uitable(fig);
zef.h_transform_table = uitable(fig);
zef.h_transform_table.ColumnName = {'ID', 'Name'};
zef.h_transform_table.ColumnEditable = [true true];
zef.h_transform_table.Data = {};
zef.h_menu_lock_on = uimenu(fig, 'Text', 'Lock on');
zef.h_menu_lock_sensor_sets_on = uimenu(fig, 'Text', 'Lock on');
zef.h_menu_lock_sensor_names_on = uimenu(fig, 'Text', 'Lock on');
zef.h_menu_lock_transforms_on = uimenu(fig, 'Text', 'Lock on');
end

function zef = i_attach_mesh_tool(testCase, zef, resolution, refinement, max_faces)
fig = uifigure('Visible', 'off');
testCase.Figures = [testCase.Figures, fig];
zef.h_mesh_tool = fig;
zef.h_edit65 = uieditfield(fig, 'numeric');
zef.h_edit65.Value = resolution;
zef.h_refinement_on = uicheckbox(fig);
zef.h_refinement_on.Value = refinement;
zef.h_max_surface_face_count = uieditfield(fig, 'numeric');
zef.h_max_surface_face_count.Limits = [-Inf Inf];
zef.h_max_surface_face_count.Value = max_faces;
end

function p = i_repo_root()
p = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function p = i_electrodes_dat()
p = fullfile(i_repo_root(), '+utilities', '+fs2zef', 'data', 'electrodes.dat');
end
