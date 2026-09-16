classdef WaitbarTest < matlab.unittest.TestCase
%WAITBARTEST  Lifecycle and API tests for zef_waitbar on MATLAB R2025a+.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    properties
        SavedWindowStyle = ""
    end

    methods (TestMethodSetup)
        function captureGrootDefault(testCase)
            testCase.SavedWindowStyle = string(get(groot, 'defaultFigureWindowStyle'));
            zef_delete_waitbar;
        end
    end

    methods (TestMethodTeardown)
        function cleanupWaitbars(testCase)
            zef_delete_waitbar;
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            delete(leftover(isvalid(leftover)));
            try
                zef_window_manager('restore');
            catch
            end
            try
                set(groot, 'defaultFigureWindowStyle', testCase.SavedWindowStyle);
            catch
            end
        end
    end

    methods (Test)

        function zeroIsProgressNotGroot(testCase)
            % zef_waitbar(0, msg) must create a window, not treat 0 as groot.
            h = zef_waitbar(0, 'zero is progress');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyNotEqual(h, groot);
            testCase.verifyEqual(local_progress(h), 0, 'AbsTol', 1e-6);
            h = zef_waitbar(0, 1, h, 'still zero');
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 0, 'AbsTol', 1e-6);
        end

        function initCurrentMaxMessageCreatesStandaloneWindow(testCase)
            h = zef_waitbar(0, 1, 'Importing.');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(char(h.WindowStyle), 'normal');
            testCase.verifyGreaterThan(numel(h.Children), 0);
            testCase.verifyTrue(contains(char(h.Name), 'ZEFFIRO Interface: Progress'));
            testCase.verifyEmpty(findall(h, 'Type', 'uilineargauge'));
            testCase.verifyNotEmpty(findall(h, 'Tag', 'progress_bar_gauge'));
            testCase.verifyEqual(local_progress(h), 0, 'AbsTol', 1e-6);
        end

        function fourArgUpdatesKeepSameHandleAndReachEnd(testCase)
            % Nested callers pass (i, N, h, msg); the same uifigure must
            % reach 100% without spawning a second window.
            h0 = zef_waitbar(0, 20, 'Importing.');
            h = h0;
            for i = 1:20
                h = zef_waitbar(i, 20, h, sprintf('Importing %d/20', i));
            end
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(h, h0);
            testCase.verifyEqual(local_progress(h), 100, 'AbsTol', 1e-6);
        end

        function ratioHandleMessageDoesNotWipeHandle(testCase)
            h = zef_waitbar(0, 'Two-arg init message');
            h2 = zef_waitbar(0.25, h, 'ratio-handle-msg');
            testCase.addTeardown(@() local_delete(h2));
            testCase.verifyTrue(isvalid(h2));
            testCase.verifyEqual(h2, h);
            testCase.verifyEqual(local_progress(h2), 25, 'AbsTol', 1e-6);
            h3 = zef_waitbar(0.5, h2);
            testCase.verifyEqual(h3, h2);
            testCase.verifyTrue(isvalid(h3));
        end

        function twoArgRatioHandleDoesNotReinitialize(testCase)
            h = zef_waitbar(0, 1, 'keep me');
            name0 = char(h.Name);
            h2 = zef_waitbar(0.4, h);
            testCase.addTeardown(@() local_delete(h2));
            testCase.verifyEqual(h2, h);
            testCase.verifyEqual(char(h2.Name), name0);
            testCase.verifyEqual(local_progress(h2), 40, 'AbsTol', 1e-6);
        end

        function closeDeletesRatherThanHides(testCase)
            % MATLAB close() on a waitbar must destroy it; hide-only would
            % leak ZefWaitbarStartTime figures across tests.
            h = zef_waitbar(0, 1, 'closeme');
            close(h);
            testCase.verifyFalse(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function updateAfterCloseRecreates(testCase)
            h = zef_waitbar(0, 1, 'closeme');
            close(h);
            h = zef_waitbar(1, 2, h, 'after close');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(char(h.Visible), 'on');
        end

        function updateAfterDeleteRecreates(testCase)
            h = zef_waitbar(0, 1, 'soon deleted');
            delete(h);
            h = zef_waitbar(1, 2, h, 'after delete');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyFalse(isempty(h));
        end

        function emptyHandleOnProgressRecreates(testCase)
            h = zef_waitbar(3, 10, [], 'recovered');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 30, 'AbsTol', 1e-6);
        end

        function createUpdateDeleteCyclesLeaveNone(testCase)
            for k = 1:40
                hk = zef_waitbar(0, 1, sprintf('cycle %d', k));
                for i = 1:8
                    hk = zef_waitbar(i, 8, hk, sprintf('cycle %d step %d', k, i));
                    testCase.verifyTrue(isvalid(hk));
                end
                close(hk);
                testCase.verifyFalse(isvalid(hk));
            end
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function rapidUpdatesDoNotErrorOrOrphan(testCase)
            h = zef_waitbar(0, 250, 'rapid');
            testCase.addTeardown(@() local_delete(h));
            for i = 1:250
                h = zef_waitbar(i, 250, h, sprintf('rapid %d', i));
            end
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 100, 'AbsTol', 1e-6);
            h = zef_waitbar(0, 250, h, 'rapid same message');
            for i = 1:250
                h = zef_waitbar(i, 250, h);
            end
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 100, 'AbsTol', 1e-6);
        end

        function errorDuringProcessingClosesViaOnCleanup(testCase)
            h = zef_waitbar(0, 1, 'will throw');
            cleanup = onCleanup(@() close(h));
            try
                zef_waitbar(1, 4, h, 'before error');
                error('WaitbarTest:Forced', 'forced failure');
            catch ME
                testCase.verifyEqual(ME.identifier, 'WaitbarTest:Forced');
            end
            clear cleanup
            testCase.verifyFalse(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function hiddenMenuOwnerStillShowsWaitbar(testCase)
            menuFig = local_fake_menu();
            menuFig.Visible = 'off';
            menuFig.ZefAlwaysShowWaitbar = false;
            menuFig.ZefUseWaitbar = true;
            testCase.addTeardown(@() local_delete(menuFig));
            h = zef_waitbar(0, 1, 'Loading fields.');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(char(string(h.Visible)), 'on');
        end

        function withMenuUpdatesAndStaysStandalone(testCase)
            menuFig = local_fake_menu();
            testCase.addTeardown(@() local_delete(menuFig));
            zef_window_manager('init');
            hm = zef_waitbar(0, 1, 'With menu');
            testCase.addTeardown(@() local_delete(hm));
            testCase.verifyEqual(char(hm.WindowStyle), 'normal');
            for i = 1:15
                hm = zef_waitbar(i, 15, hm, 'With menu');
            end
            testCase.verifyTrue(isvalid(hm));
            testCase.verifyGreaterThan(numel(hm.Children), 0);
            zef_window_manager('standalone', hm);
            testCase.verifyEqual(char(hm.WindowStyle), 'normal');
            testCase.verifyTrue(zef_window_manager('is_protected', hm, 'close'));
        end

        function useWaitbarFalseStillReturnsValidHandle(testCase)
            clear zef_waitbar
            menuFig = local_ensure_menu();
            had_prop = isprop(menuFig, 'ZefUseWaitbar');
            old_use = true;
            if had_prop
                old_use = menuFig.ZefUseWaitbar;
            else
                addprop(menuFig, 'ZefUseWaitbar');
            end
            menuFig.ZefUseWaitbar = false;
            testCase.addTeardown(@() local_restore_use_waitbar(menuFig, had_prop, old_use));
            h = zef_waitbar(0, 1, 'hidden');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(char(string(h.Visible)), 'off');
            h = zef_waitbar(0.5, h, 'still hidden');
            testCase.verifyTrue(isvalid(h));
            close(h);
            testCase.verifyFalse(isvalid(h));
        end

        function closeWaitbarOnInvalidDoesNotThrow(testCase)
            zef_close_waitbar([]);
            h = zef_waitbar(0, 1, 'temp');
            delete(h);
            zef_close_waitbar(h);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function nestedStiffnessAndAdjacencyKeepParent(testCase)
            h = zef_waitbar(0, 1, 'Lead field.');
            testCase.addTeardown(@() local_delete(h));
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            A = zef_adjacency_matrix(nodes, tetra);
            testCase.verifyEqual(size(A), [4 4]);
            testCase.verifyTrue(isvalid(h));
            vol = abs(zef_tetra_volume(nodes, tetra, true));
            tensor = [1; 1; 1; 0; 0; 0];
            S = zef_stiffness_matrix(nodes, tetra, vol, tensor);
            testCase.verifyEqual(size(S, 1), 4);
            testCase.verifyTrue(isvalid(h));
            close(h);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function nestedSourceTetraKeepsParent(testCase)
            h = zef_waitbar(0, 1, 'parent');
            testCase.addTeardown(@() local_delete(h));
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            tetra = [1 2 3 4];
            zef_source_tetra([0.1 0.1 0.1], tetra, nodes, 1);
            testCase.verifyTrue(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEqual(numel(leftover), 1);
            close(h);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function nestedDoubleCloseDoesNotDestroyParent(testCase)
            h = zef_waitbar(0, 1, 'parent pipeline');
            testCase.addTeardown(@() local_delete(h));
            nestedDoubleCloseJob();
            testCase.verifyTrue(isvalid(h));
            close(h);
            testCase.verifyFalse(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function ownerCloseDestroysEvenIfNestedForgot(testCase)
            h = zef_waitbar(0, 1, 'parent pipeline');
            testCase.addTeardown(@() local_delete(h));
            nestedInitNoCloseJob();
            testCase.verifyTrue(isvalid(h));
            close(h);
            testCase.verifyFalse(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function sequentialInitFromSameCallerClosesOnce(testCase)
            % Two initialize calls from one function reuse the singleton as
            % a replacement, not a nest. One close must still destroy it.
            h1 = zef_waitbar(0, 1, 'first');
            h2 = zef_waitbar(0, 1, 'second');
            testCase.verifyEqual(h1, h2);
            close(h2);
            testCase.verifyFalse(isvalid(h1));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function nestedInitCloseKeepsParentHandle(testCase)
            % zef_tetra_turn / zef_fix_negatives initialize+close while a
            % parent pipeline waitbar is open. The parent handle must stay
            % valid so later close(h) does not throw Invalid figure handle.
            h = zef_waitbar(0, 1, 'Mesh post-processing');
            testCase.addTeardown(@() local_delete(h));
            nestedWaitbarJob();
            testCase.verifyTrue(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEqual(numel(leftover), 1);
            h = zef_waitbar(0, 1, h, 'Surface triangles.');
            for i = 1:5
                h = zef_waitbar(i, 5, h, 'Surface triangles.');
            end
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 100, 'AbsTol', 1e-6);
            close(h);
            testCase.verifyFalse(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function tetraTurnNestedCloseKeepsParent(testCase)
            h = zef_waitbar(0, 1, 'Mesh post-processing');
            testCase.addTeardown(@() local_delete(h));
            zef = struct('mesh_optimization_repetitions', 1);
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            tetra = [1 2 3 4];
            [tetra_out, flag_val] = zef_tetra_turn(zef, nodes, tetra, 0);
            testCase.verifyEqual(size(tetra_out, 2), 4);
            testCase.verifyTrue(ismember(flag_val, [-1 1]));
            testCase.verifyTrue(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEqual(numel(leftover), 1);
            close(h);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function fixNegativesNestedCloseKeepsParent(testCase)
            h = zef_waitbar(0, 1, 'Mesh post-processing');
            testCase.addTeardown(@() local_delete(h));
            zef = struct('meshing_threshold', 0.5, 'mesh_optimization_repetitions', 1);
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            tetra = [1 2 3 4];
            [nodes_out, flag_val] = zef_fix_negatives(zef, nodes, tetra);
            testCase.verifyEqual(size(nodes_out), size(nodes));
            testCase.verifyTrue(ismember(flag_val, [-1 1]));
            testCase.verifyTrue(isvalid(h));
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEqual(numel(leftover), 1);
            close(h);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function newInitReusesSingletonHandle(testCase)
            h1 = zef_waitbar(0, 1, 'first');
            h2 = zef_waitbar(0, 1, 'second');
            testCase.addTeardown(@() local_delete(h2));
            testCase.verifyTrue(isvalid(h1));
            testCase.verifyEqual(h1, h2);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEqual(numel(leftover), 1);
            lbl = findall(h2, 'Tag', 'progress_bar_text');
            testCase.verifyEqual(char(string(lbl.Text)), 'second');
        end

        function arrangeCloseDoesNotDestroyWaitbar(testCase)
            zef_window_manager('init');
            menuFig = uifigure('Visible', 'off', 'Name', 'ZEFFIRO Interface: Menu tool');
            segFig = uifigure('Visible', 'off', 'Name', 'ZEFFIRO Interface: Segmentation tool');
            extra = uifigure('Visible', 'off', 'Name', 'ZEFFIRO Interface: Mesh tool');
            testCase.addTeardown(@() local_delete([menuFig, segFig, extra]));
            h = zef_waitbar(0, 1, 'protected');
            testCase.addTeardown(@() local_delete(h));
            zef_arrange_windows('close', 'tools', 'all');
            testCase.verifyTrue(isvalid(h));
            testCase.verifyTrue(isvalid(menuFig));
            testCase.verifyTrue(isvalid(segFig));
            testCase.verifyFalse(isvalid(extra));
        end

        function waitbarStaysNormalWhenFactoryDefaultIsDocked(testCase)
            testCase.assumeTrue(strcmp(char(get(groot, 'factoryFigureWindowStyle')), 'docked'));
            set(groot, 'defaultFigureWindowStyle', 'docked');
            zef_window_manager('init');
            h = zef_waitbar(0, 1, 'docked-default');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyEqual(char(h.WindowStyle), 'normal');
            h = zef_waitbar(1, 2, h, 'still standalone');
            testCase.verifyEqual(char(h.WindowStyle), 'normal');
        end

        function hexaToTetraClosesWaitbar(testCase)
            hexa = repmat(1:8, 80, 1);
            labels = ones(80, 1);
            for k = 1:12
                [tetra, lab] = zef_hexa_to_tetra(hexa, labels);
                testCase.verifyEqual(size(tetra, 1), 480);
                testCase.verifyEqual(numel(lab), 480);
                leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
                testCase.verifyEmpty(leftover, sprintf('leftover waitbar after hexa_to_tetra run %d', k));
            end
        end

        function adjacencyAndStiffnessCloseWaitbar(testCase)
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
            tetra = [1 2 3 4; 2 3 4 8; 2 5 3 8; 5 6 8 2; 3 7 8 4; 4 6 8 7];
            for k = 1:8
                A = zef_adjacency_matrix(nodes, tetra);
                testCase.verifyEqual(size(A), [8 8]);
                leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
                testCase.verifyEmpty(leftover, sprintf('leftover after adjacency %d', k));
            end
            vol = abs(zef_tetra_volume(nodes, tetra, true));
            tensor = [ones(3, size(tetra, 1)); zeros(3, size(tetra, 1))];
            for k = 1:8
                S = zef_stiffness_matrix(nodes, tetra, vol, tensor);
                testCase.verifyEqual(size(S, 1), 8);
                leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
                testCase.verifyEmpty(leftover, sprintf('leftover after stiffness %d', k));
            end
        end

        function sequentialRealCallersDoNotCorruptNextRun(testCase)
            hexa = repmat(1:8, 40, 1);
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            tetra = [1 2 3 4];
            for k = 1:10
                zef_hexa_to_tetra(hexa);
                zef_adjacency_matrix(nodes, tetra);
                vol = abs(zef_tetra_volume(nodes, tetra, true));
                tensor = [1; 1; 1; 0; 0; 0];
                zef_stiffness_matrix(nodes, tetra, vol, tensor);
                zef_source_tetra([0.1 0.1 0.1], tetra, nodes, 1);
                leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
                testCase.verifyEmpty(leftover, sprintf('leftover after sequential pass %d', k));
            end
        end

        function mixedSignaturesInOneSession(testCase)
            h = zef_waitbar(0, 1, 'phase 1');
            h = zef_waitbar(1, 4, h);
            h = zef_waitbar(0.5, h, 'phase 2');
            h = zef_waitbar(3, 4, h, 'phase 3');
            h = zef_waitbar(1, 1, h, 'done');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 100, 'AbsTol', 1e-6);
            close(h);
            h = zef_waitbar(0, 'restart');
            testCase.addTeardown(@() local_delete(h));
            h = zef_waitbar(0.75, h);
            testCase.verifyTrue(isvalid(h));
            close(h);
            leftover = findall(groot, '-property', 'ZefWaitbarStartTime');
            testCase.verifyEmpty(leftover);
        end

        function vectorProgressInitIsAccepted(testCase)
            h = zef_waitbar([0 0], [1 1], 'Inflating.');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyTrue(isvalid(h));
            h = zef_waitbar([0.5 0.25], [1 1], h, 'Inflating.');
            testCase.verifyTrue(isvalid(h));
            testCase.verifyEqual(local_progress(h), 50, 'AbsTol', 1e-6);
            close(h);
            testCase.verifyFalse(isvalid(h));
        end

        function percentTextMatchesFilledBarImmediately(testCase)
            h = zef_waitbar(0.78, 'Loading >100 MB fields: 7 / 9.');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyEmpty(findall(h, 'Type', 'uilineargauge'));
            testCase.verifyEqual(local_progress(h), 78, 'AbsTol', 1e-6);
            pct = findall(h, 'Tag', 'progress_bar_percent');
            testCase.verifyNotEmpty(pct);
            testCase.verifyEqual(char(string(pct.Text)), '78%');
            msg = findall(h, 'Tag', 'progress_bar_text');
            testCase.verifyEqual(char(string(msg.Text)), 'Loading >100 MB fields: 7 / 9.');
        end

        function percentUpdatesFromZeroToComplete(testCase)
            h = zef_waitbar(0, 9, 'Loading >100 MB fields: 0 / 9.');
            testCase.addTeardown(@() local_delete(h));
            testCase.verifyEqual(char(string(findall(h, 'Tag', 'progress_bar_percent').Text)), '0%');
            h = zef_waitbar(7, 9, h, 'Loading >100 MB fields: 7 / 9.');
            testCase.verifyEqual(local_progress(h), 100 * 7 / 9, 'AbsTol', 1e-6);
            testCase.verifyEqual(char(string(findall(h, 'Tag', 'progress_bar_percent').Text)), '78%');
            h = zef_waitbar(9, 9, h, 'Loading >100 MB fields: 9 / 9.');
            testCase.verifyEqual(local_progress(h), 100, 'AbsTol', 1e-6);
            testCase.verifyEqual(char(string(findall(h, 'Tag', 'progress_bar_percent').Text)), '100%');
        end

        function etaIsBlankUntilElapsedTimeExists(testCase)
            h = zef_waitbar(0.35, 'Building mesh.');
            testCase.addTeardown(@() local_delete(h));
            ready = findall(h, 'Tag', 'progress_bar_ready_text');
            testCase.verifyEqual(strtrim(char(string(ready.Text))), '');
        end

        function themeActionRepaintsOpenWaitbar(testCase)
            old_zef = [];
            had_zef = evalin('base', 'exist(''zef'',''var'')');
            if had_zef
                old_zef = evalin('base', 'zef');
            end
            testCase.addTeardown(@() local_restore_zef(had_zef, old_zef));
            assignin('base', 'zef', struct('font_size', 12));
            h = zef_waitbar(0.4, 'Theming.');
            testCase.addTeardown(@() local_delete(h));
            h.Color = [1 0 0];
            zef_waitbar('theme');
            theme = zef_ui_theme();
            testCase.verifyEqual(h.Color, theme.color.bg, 'AbsTol', 1e-6);
            msg = findall(h, 'Tag', 'progress_bar_text');
            testCase.verifyEqual(msg.FontColor, theme.color.text, 'AbsTol', 1e-6);
        end

    end

end

function nestedInitNoCloseJob()
zef_waitbar(0, 1, 'nested forgot');
end

function nestedDoubleCloseJob()
h = zef_waitbar(0, 1, 'nested');
zef_close_waitbar(h);
zef_close_waitbar(h);
end

function nestedWaitbarJob()
% Distinct stack frame from WaitbarTest methods so nest counting treats
% this as a nested owner (same pattern as zef_tetra_turn).
h = zef_waitbar(0, 1, 'Mesh optimization.');
zef_waitbar(1, 2, h, 'Mesh optimization.');
if isvalid(h)
    close(h);
end
end

function v = local_progress(h)
v = NaN;
if isprop(h, 'ZefWaitbarValue') && ~isempty(h.ZefWaitbarValue)
    v = double(h.ZefWaitbarValue);
    return
end
end

function local_delete(h)
if isempty(h)
    return
end
for i = 1:numel(h)
    if isvalid(h(i))
        try
            set(h(i), 'CloseRequestFcn', '');
            set(h(i), 'DeleteFcn', '');
            delete(h(i));
        catch
        end
    end
end
end

function menuFig = local_ensure_menu()
found = findall(groot, 'ZefTool', 'zef_menu_tool');
found = found(arrayfun(@(h) isgraphics(h) && isvalid(h), found));
if ~isempty(found)
    menuFig = found(1);
    return
end
menuFig = local_fake_menu();
end

function local_restore_use_waitbar(menuFig, had_prop, old_use)
if ~isgraphics(menuFig) || ~isvalid(menuFig)
    return
end
if had_prop
    menuFig.ZefUseWaitbar = old_use;
end
end

function menuFig = local_fake_menu()
menuFig = uifigure('Visible', 'off', 'Name', 'ZEFFIRO Interface: Menu tool');
addprop(menuFig, 'ZefTool'); menuFig.ZefTool = 'zef_menu_tool';
addprop(menuFig, 'ZefUseWaitbar'); menuFig.ZefUseWaitbar = true;
addprop(menuFig, 'ZefAlwaysShowWaitbar'); menuFig.ZefAlwaysShowWaitbar = true;
addprop(menuFig, 'ZefVerboseMode'); menuFig.ZefVerboseMode = false;
addprop(menuFig, 'ZefUseLog'); menuFig.ZefUseLog = false;
addprop(menuFig, 'ZefFontSize'); menuFig.ZefFontSize = 12;
addprop(menuFig, 'ZefWaitbarSize'); menuFig.ZefWaitbarSize = [1 0.7];
addprop(menuFig, 'ZefWaitbarHandle'); menuFig.ZefWaitbarHandle = [];
addprop(menuFig, 'ZefTaskId'); menuFig.ZefTaskId = 0;
addprop(menuFig, 'ZefRestartTime'); menuFig.ZefRestartTime = now;
addprop(menuFig, 'ZefCurrentLogFile'); menuFig.ZefCurrentLogFile = '';
menuFig.Position = [80 400 500 40];
end

function local_restore_zef(had_zef, old_zef)
if had_zef
    assignin('base', 'zef', old_zef);
else
    evalin('base', 'clear zef');
end
end
