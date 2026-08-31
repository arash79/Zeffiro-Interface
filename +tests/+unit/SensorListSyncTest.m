classdef SensorListSyncTest < matlab.unittest.TestCase
%SENSORLISTSYNCTEST  Figure-tool sensor count matches listed rows.

    methods (Test)
        function emptyProjectListsNothing(testCase)
            zef = struct();
            [names, colors, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 0);
            testCase.verifyEmpty(names);
            testCase.verifyEqual(size(colors, 1), 0);
        end

        function oneSensorIsListed(testCase)
            zef = struct('current_sensors', 's', 's_points', [0 0 0], ...
                's_name_list', {{'Cz'}}, 's_name', 'EEG');
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, 1);
            testCase.verifyEqual(string(names{1}), "Cz");
        end

        function hiddenVisibilityDoesNotDropRows(testCase)
            n_pts = 72;
            zef = struct();
            zef.current_sensors = 's';
            zef.s_points = rand(n_pts, 3);
            zef.s_visible_list = false(n_pts, 1);
            zef.s_name = 'EEG';
            [names, ~, n] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n, n_pts);
            testCase.verifyEqual(numel(names), n_pts);
        end

        function countMatchesForTypicalSizes(testCase)
            sizes = [0, 1, 32, 72, 128, 400];
            for i = 1:numel(sizes)
                n_pts = sizes(i);
                zef = struct();
                zef.current_sensors = 's';
                zef.s_points = rand(n_pts, 3);
                zef.s_name = 'MEG';
                [names, colors, n] = zef_sensor_list_items(zef);
                testCase.verifyEqual(n, n_pts);
                testCase.verifyEqual(numel(names), n_pts);
                testCase.verifyEqual(size(colors, 1), n_pts);
            end
        end

        function secondLoadReplacesFirstSet(testCase)
            zef = struct('current_sensors', 's', 's_points', rand(10, 3), ...
                's_name', 'EEG');
            [names1, ~, n1] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n1, 10);
            zef.s_points = rand(3, 3);
            [names2, ~, n2] = zef_sensor_list_items(zef);
            testCase.verifyEqual(n2, 3);
            testCase.verifyEqual(numel(names2), 3);
            testCase.verifyNotEqual(numel(names1), numel(names2));
        end
    end
end
