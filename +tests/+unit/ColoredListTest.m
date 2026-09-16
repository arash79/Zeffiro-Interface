classdef ColoredListTest < matlab.unittest.TestCase
%COLOREDLISTTEST  Color-swatch lists on HTML, uihtml, and table backends.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    properties
        Figures = gobjects(0)
    end

    properties (TestParameter)
        Backend = {'html', 'uihtml'}
    end

    methods (TestMethodTeardown)
        function cleanupFigures(testCase)
            for i = 1:numel(testCase.Figures)
                if isgraphics(testCase.Figures(i)) && isvalid(testCase.Figures(i))
                    delete(testCase.Figures(i));
                end
            end
            testCase.Figures = gobjects(0);
        end
    end

    methods (Access = private)
        function h = track(testCase, h)
            testCase.Figures(end+1) = h; %#ok<AGROW>
        end

        function f = newFigure(testCase)
            f = testCase.track(figure('Visible', 'off', 'WindowStyle', 'normal'));
        end
    end

    methods (Static, Access = private)
        function names = listNames(h)
            ud = h.UserData;
            if isstruct(ud) && isfield(ud, 'Names') && ~isempty(ud.Names)
                names = string(ud.Names(:));
                return
            end
            if isprop(h, 'Style') && strcmpi(char(string(h.Style)), 'listbox')
                names = string(h.String(:));
                return
            end
            if isprop(h, 'Data') && iscell(h.Data)
                names = strtrim(string(h.Data(:, end)));
                return
            end
            names = strings(0, 1);
        end
    end

    methods (Test)

        function htmlSupportedMatchesRelease(testCase)
            % html_supported is year < 2025 from version('-release').
            rel = version('-release');
            year = sscanf(char(string(rel)), '%d');
            expect_html = isempty(year) || year < 2025;
            testCase.verifyEqual(zef_colored_list('html_supported'), expect_html);
        end

        function defaultCreateFollowsRelease(testCase)
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'def');
            if zef_colored_list('html_supported')
                testCase.verifyTrue(isprop(h, 'Style') && strcmpi(h.Style, 'listbox'));
            else
                testCase.verifyTrue(isa(h, 'matlab.ui.control.HTML') || ...
                    strcmpi(char(string(h.Type)), 'uihtml'));
            end
        end

        function htmlListboxShowsRawTagsOnR2025Plus(testCase)
            v = ver('MATLAB');
            rel = char(v.Release);
            year = sscanf(rel, '(R%d');
            testCase.assumeTrue(~isempty(year) && year >= 2025, ...
                'HTML listbox breakage applies from R2025a.');
            testCase.verifyFalse(zef_colored_list('html_supported'));
            f = testCase.newFigure();
            html = '<HTML><BODY>&nbsp <SPAN bgcolor="rgb(255,0,0)"> &nbsp </SPAN> Scalp</BODY></HTML>';
            lb = uicontrol(f, 'Style', 'listbox', 'String', {html});
            testCase.verifyTrue(contains(lb.String{1}, '<HTML>'));
            testCase.verifyTrue(contains(lb.String{1}, 'SPAN'));
        end

        function helperStoresPlainNamesAndColorStyles(testCase)
            % UserData.Names stay plain; HTML tags must not leak into
            % listNames so callers can round-trip labels.
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'comp');
            zef_colored_list('set', h, {'Scalp', 'Skull'}, [1 0 0; 0 1 0]);
            names = tests.unit.ColoredListTest.listNames(h);
            testCase.verifyEqual(names(1), "Scalp");
            testCase.verifyEqual(strtrim(names(2)), "Skull");
            testCase.verifyFalse(any(contains(names, '<HTML>')));
            zef_colored_list('value', h, 2);
            testCase.verifyEqual(zef_colored_list('value', h), 2);
        end

        function updateFigDetailsFillsVisibleCompartmentsAndSensors(testCase)
            % zef_update_fig_details walks *_on/*_visible tags (reversed)
            % and visible_list sensors into the three Figure-tool lists.
            f = testCase.newFigure();
            zef = struct();
            zef.h_compartment_visible_color = zef_colored_list('create', f, [0.05 0.05 0.4 0.9], 'c');
            zef.h_sensor_visible_color = zef_colored_list('create', f, [0.55 0.05 0.4 0.9], 's');
            zef.h_system_information = zef_colored_list('create', f, [0.05 0.05 0.1 0.1], 'system_information', ...
                'ShowSwatches', false);
            zef.compartment_tags = {'a', 'b'};
            zef.a_on = 1; zef.a_visible = 1; zef.a_name = 'Scalp'; zef.a_color = [1 0.5 0.5];
            zef.b_on = 1; zef.b_visible = 1; zef.b_name = 'Skull'; zef.b_color = [0.9 0.9 0.2];
            zef.current_sensors = 's';
            zef.s_points = [0 0 0; 1 0 0];
            zef.s_visible_list = [1; 1];
            zef.s_name_list = {'EEG-1'; 'EEG-2'};
            zef.s_color_table = [0 1 0; 0 0 1];
            zef.nodes = zeros(4, 3);
            zef.tetra = zeros(5, 4);
            zef.on_screen = 2;
            zef.inv_scale = 2;
            zef.source_direction_mode = 1;
            zef.reconstruction_type = 1;
            zef = zef_update_fig_details(zef);
            names = tests.unit.ColoredListTest.listNames(zef.h_compartment_visible_color);
            testCase.verifyEqual(names(:), ["Skull"; "Scalp"]);
            testCase.verifyFalse(any(contains(names, '<HTML>')));
            sensors = tests.unit.ColoredListTest.listNames(zef.h_sensor_visible_color);
            testCase.verifyEqual(sensors(:), ["EEG-1"; "EEG-2"]);
            info = tests.unit.ColoredListTest.listNames(zef.h_system_information);
            testCase.verifyTrue(any(contains(info, 'Nodes: 4')));
            testCase.verifyTrue(any(contains(info, 'Visualization: Surfaces')));
        end

        function updateFigDetailsListsSensorsWhenAllInvisible(testCase)
            f = testCase.newFigure();
            zef = struct();
            zef.h_sensor_visible_color = zef_colored_list('create', f, [0.55 0.05 0.4 0.9], 's');
            zef.current_sensors = 's';
            zef.s_points = rand(72, 3);
            zef.s_visible_list = false(72, 1);
            zef.s_name_list = arrayfun(@(k) sprintf('Ch %d', k), 1:72, 'UniformOutput', false)';
            zef.s_name = 'EEG';
            zef = zef_update_fig_details(zef);
            names = tests.unit.ColoredListTest.listNames(zef.h_sensor_visible_color);
            testCase.verifyEqual(numel(names), 72);
            testCase.verifyEqual(strtrim(names(1)), "Ch 1");
        end

        function backendRoundTrip(testCase, Backend)
            % Parameterized html vs uihtml: multiselect, empty, clamp 99→2.
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'rt', ...
                'Backend', Backend, 'Multiselect', true, 'AllowEmpty', true);
            zef_colored_list('set', h, {'Scalp', 'Skull', 'CSF'}, [1 0 0; 0 1 0; 0 0 1]);
            zef_colored_list('value', h, [1 3]);
            testCase.verifyEqual(zef_colored_list('value', h), [1 3]);
            zef_colored_list('value', h, []);
            testCase.verifyTrue(isempty(zef_colored_list('value', h)));
            zef_colored_list('value', h, [2 99]);
            testCase.verifyEqual(zef_colored_list('value', h), 2);
            names = tests.unit.ColoredListTest.listNames(h);
            testCase.verifyTrue(any(contains(names, 'Scalp')));
            testCase.verifyTrue(any(contains(names, 'Skull')));
            testCase.verifyFalse(any(contains(names, '<HTML>')));
        end

        function backendPreservesSelectionOnSet(testCase, Backend)
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'ps', ...
                'Backend', Backend);
            zef_colored_list('set', h, {'A', 'B', 'C'}, [1 0 0; 0 1 0; 0 0 1]);
            zef_colored_list('value', h, 2);
            zef_colored_list('set', h, {'A', 'B', 'C'}, [1 0 0; 0 1 0; 0 0 1]);
            testCase.verifyEqual(zef_colored_list('value', h), 2);
        end

        function backendParcellationMarkers(testCase, Backend)
            % V/X markers as used by zef_update_parcellation.
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'pm', ...
                'Backend', Backend, 'Multiselect', true, 'AllowEmpty', true);
            zef_colored_list('set', h, {'lh001 : cortex', 'rh002 : white'}, ...
                [0.2 0.4 0.8; 0.9 0.1 0.1], ...
                'Markers', {'V', 'X'}, 'MarkerColors', [0 0.6 0; 1 0 0]);
            names = tests.unit.ColoredListTest.listNames(h);
            testCase.verifyTrue(any(contains(names, 'lh001 : cortex')));
            if strcmp(Backend, 'html')
                testCase.verifyTrue(contains(h.String{1}, '>V</SPAN>'));
                testCase.verifyTrue(contains(h.String{2}, '>X</SPAN>'));
            else
                ud = h.UserData;
                testCase.verifyEqual(string(ud.Markers), ["V", "X"]);
            end
            zef_colored_list('value', h, [1 2]);
            testCase.verifyEqual(zef_colored_list('value', h), [1 2]);
        end

        function backendKalmanStyleSelection(testCase, Backend)
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'kf', ...
                'Backend', Backend, 'Multiselect', true, 'AllowEmpty', true);
            names = arrayfun(@(k) sprintf('p%03d', k), 1:120, 'UniformOutput', false);
            colors = repmat([0.5 0.5 0.5], 120, 1);
            zef_colored_list('set', h, names, colors);
            zef_colored_list('value', h, [23, 77, 110]);
            testCase.verifyEqual(zef_colored_list('value', h), [23 77 110]);
        end

        function htmlTriggerUsesButtonDownNotCallback(testCase)
            % Figure-tool lists must fire on ButtonDownFcn, not Callback.
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'bd', ...
                'Backend', 'html', ...
                'Callback', 'disp(1)', ...
                'Trigger', 'buttondown');
            testCase.verifyTrue(ischar(h.ButtonDownFcn) || isstring(h.ButtonDownFcn));
            testCase.verifyTrue(isempty(h.Callback) || isequal(h.Callback, ''));
        end

        function stripCallbackDoesNotNeedGcbo(testCase, Backend)
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'strip_list', ...
                'Backend', Backend);
            zef_colored_list('set', h, {'ID: 1', 'ID: 2'}, [1 0 0; 0 0 1]);
            zef_colored_list('value', h, 2);
            testCase.verifyEqual(zef_colored_list('value', h), 2);
        end

        function detailsListHasNoSwatches(testCase)
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'd', ...
                'ShowSwatches', false);
            zef_colored_list('set', h, {'Nodes: 4', 'Tetrahedra: 5'}, []);
            names = tests.unit.ColoredListTest.listNames(h);
            testCase.verifyEqual(names(:), ["Nodes: 4"; "Tetrahedra: 5"]);
            ud = h.UserData;
            testCase.verifyFalse(ud.ShowSwatches);
        end

        function showChecksStoresFlagWithoutReplacingNames(testCase)
            f = testCase.newFigure();
            h = zef_colored_list('create', f, [0.1 0.1 0.8 0.8], 'chk', ...
                'Backend', 'uihtml', 'ShowChecks', true, 'ShowSwatches', false);
            zef_colored_list('set', h, {'Electrodes 1', 'Electrodes 2'}, []);
            ud = h.UserData;
            testCase.verifyTrue(logical(ud.ShowChecks));
            testCase.verifyFalse(logical(ud.ShowSwatches));
            names = tests.unit.ColoredListTest.listNames(h);
            testCase.verifyEqual(names(:), ["Electrodes 1"; "Electrodes 2"]);
            zef_colored_list('value', h, 1);
            testCase.verifyEqual(zef_colored_list('value', h), 1);
        end

    end

end
