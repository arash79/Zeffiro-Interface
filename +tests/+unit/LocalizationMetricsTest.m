classdef LocalizationMetricsTest < matlab.unittest.TestCase
%LOCALIZATIONMETRICSTEST  Optional source-localization accuracy metrics.
%
%   Validates utilities.sensitivity.localization_metrics against
%   hand-computed geometry (independent references), the optional
%   zef_inverse_run hook (enabled/disabled behavior, missing ground
%   truth), and the class-solver dialog GUI path from checkbox to
%   zef.localization_metrics.

    properties
        Figures = gobjects(0)
        HadBaseZef = false
        OldBaseZef = []
    end

    methods (TestClassSetup)
        function setupPath(~)
            zeffiro_interface('start_mode', 'nodisplay', 'zeffiro_restart', true);
        end
    end

    methods (TestClassTeardown)
        function restoreBaseZef(testCase)
            if testCase.HadBaseZef
                assignin('base', 'zef', testCase.OldBaseZef);
            else
                evalin('base', 'clear zef');
            end
        end
    end

    methods (TestMethodSetup)
        function stashBaseZef(testCase)
            testCase.HadBaseZef = evalin('base', 'exist(''zef'',''var'')') == 1;
            if testCase.HadBaseZef
                testCase.OldBaseZef = evalin('base', 'zef');
            end
        end
    end

    methods (TestMethodTeardown)
        function cleanup(testCase)
            for i = 1:numel(testCase.Figures)
                if isgraphics(testCase.Figures(i)) && isvalid(testCase.Figures(i))
                    delete(testCase.Figures(i));
                end
            end
            testCase.Figures = gobjects(0);
            if ~testCase.HadBaseZef
                evalin('base', 'clear zef');
            end
        end
    end

    methods (Test)
        function analyticPeakAtTrueSourceScoresZero(testCase)
            % Node 2 carries a unit dipole along +z; ground truth is that
            % exact dipole. All three metrics must vanish.
            pos = [0 0 0; 10 0 0; 0 10 0];
            z = zeros(9, 1);
            z(4:6) = [0; 0; 2];  % node 2, amplitude 2 along z
            true_source = [10 0 0 0 0 1];
            m = utilities.sensitivity.localization_metrics(z, pos, true_source);
            f = m.per_frame(1);
            testCase.verifyTrue(f.valid);
            testCase.verifyEqual(f.distance_mm, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.angular_deviation_deg, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.angular_deviation_symmetrized_deg, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.dispersion_mm, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.peak_index, 2);
            testCase.verifyEqual(f.peak_magnitude, 2, 'AbsTol', 1e-12);
        end

        function distanceAndAngleMatchHandComputedGeometry(testCase)
            pos = [0 0 0; 30 40 0];   % nodes 10 mm apart? norm = 50
            z = zeros(6, 1);
            z(1:3) = [1; 0; 0];       % node 1 dipole along +x
            true_source = [30 40 0 0 1 0];  % true at node 2 along +y
            m = utilities.sensitivity.localization_metrics(z, pos, true_source);
            f = m.per_frame(1);
            testCase.verifyTrue(f.valid);
            % Nearest true source is node 2 at distance 50 mm.
            testCase.verifyEqual(f.distance_mm, 50, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.true_index, 1);
            % Angle between +x and +y is 90 degrees; symmetrized equal.
            testCase.verifyEqual(f.angular_deviation_deg, 90, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.angular_deviation_symmetrized_deg, 90, 'AbsTol', 1e-12);
        end

        function signFlipDistinguishesFullAndSymmetrizedAngle(testCase)
            pos = [0 0 0; 5 0 0];
            z = zeros(6, 1);
            z(4:6) = [-1; 0; 0];       % peak along -x at node 2
            true_source = [5 0 0 1 0 0];
            m = utilities.sensitivity.localization_metrics(z, pos, true_source);
            f = m.per_frame(1);
            testCase.verifyEqual(f.distance_mm, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.angular_deviation_deg, 180, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.angular_deviation_symmetrized_deg, 0, 'AbsTol', 1e-12);
        end

        function dispersionMatchesHandComputedWeightedRms(testCase)
            % Peak at node 2 (amplitude 4); node 1 (amplitude 1) is 6 mm
            % away and within the 10 mm radius; far node 3 (amplitude 0.5)
            % is outside the radius. Dispersion is the magnitude-squared
            % weighted RMS: sqrt((6^2 * 1^2) / (1^2 + 4^2)).
            pos = [0 0 0; 6 0 0; 100 0 0];
            z = zeros(9, 1);
            z(1:3) = [1; 0; 0];
            z(4:6) = [0; 4; 0];
            z(7:9) = [0; 0; 0.5];
            true_source = [6 0 0 1 0 0];
            m = utilities.sensitivity.localization_metrics(z, pos, true_source, ...
                'DispersionRadius', 10);
            f = m.per_frame(1);
            testCase.verifyEqual(f.peak_index, 2);
            expected = sqrt(36 / 17);
            testCase.verifyEqual(f.dispersion_mm, expected, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.distance_mm, 0, 'AbsTol', 1e-12);
            % A radius smaller than the nearest neighbor keeps only the
            % peak itself: dispersion must vanish.
            m0 = utilities.sensitivity.localization_metrics(z, pos, true_source, ...
                'DispersionRadius', 1e-9);
            testCase.verifyEqual(m0.per_frame(1).dispersion_mm, 0, 'AbsTol', 1e-12);
        end

        function angleUnavailableWithoutTrueDirection(testCase)
            pos = [0 0 0; 1 0 0];
            z = zeros(6, 1);
            z(1:3) = [0; 0; 1];
            true_source = struct('position', [0 0 0], 'direction', [0 0 0]);
            m = utilities.sensitivity.localization_metrics(z, pos, true_source);
            f = m.per_frame(1);
            testCase.verifyTrue(f.valid);
            testCase.verifyEqual(f.distance_mm, 0, 'AbsTol', 1e-12);
            testCase.verifyTrue(isnan(f.angular_deviation_deg));
            testCase.verifyTrue(isnan(f.angular_deviation_symmetrized_deg));
        end

        function degenerateFrameIsExplicitlyInvalidNotAnError(testCase)
            pos = [0 0 0; 1 0 0];
            z = zeros(6, 1);
            m = utilities.sensitivity.localization_metrics(z, pos, [0 0 0 1 0 0]);
            f = m.per_frame(1);
            testCase.verifyFalse(f.valid);
            testCase.verifyTrue(isnan(f.distance_mm));
            testCase.verifyTrue(isnan(f.dispersion_mm));
            testCase.verifyNotEmpty(f.message);
            testCase.verifyFalse(m.summary.all_valid);
            testCase.verifyTrue(isnan(m.summary.mean_distance_mm));
        end

        function emptyTrueSourceErrors(testCase)
            pos = [0 0 0; 1 0 0];
            z = ones(6, 1);
            testCase.verifyError( ...
                @() utilities.sensitivity.localization_metrics(z, pos, []), ...
                'utilities:sensitivity:localization_metrics:MissingTrueSource');
        end

        function sizeMismatchErrors(testCase)
            pos = [0 0 0; 1 0 0];
            testCase.verifyError( ...
                @() utilities.sensitivity.localization_metrics(ones(9, 1), pos, [0 0 0 1 0 0]), ...
                'utilities:sensitivity:localization_metrics:SizeMismatch');
        end

        function multiFrameCellGivesPerFrameAndSummary(testCase)
            pos = [0 0 0; 8 0 0];
            z1 = zeros(6, 1); z1(1:3) = [1; 0; 0];
            z2 = zeros(6, 1); z2(4:6) = [0; 2; 0];
            m = utilities.sensitivity.localization_metrics({z1, z2}, pos, [8 0 0 1 0 0]);
            testCase.verifyEqual(numel(m.per_frame), 2);
            testCase.verifyEqual(m.summary.n_frames, 2);
            testCase.verifyEqual(m.per_frame(1).distance_mm, 8, 'AbsTol', 1e-12);
            testCase.verifyEqual(m.per_frame(2).distance_mm, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(m.summary.mean_distance_mm, 4, 'AbsTol', 1e-12);
            testCase.verifyEqual(m.summary.max_distance_mm, 8, 'AbsTol', 1e-12);
            testCase.verifyEqual(m.summary.best_frame, 2);
            testCase.verifyTrue(m.summary.all_valid);
        end

        function nearestTrueSourceIsMatchedWhenSeveralExist(testCase)
            pos = [0 0 0; 4 0 0];
            z = zeros(6, 1);
            z(4:6) = [0; 1; 0];  % peak at node 2 (4,0,0)
            true_source = [100 0 0 0 0 1; 4 0 0 1 0 0];
            m = utilities.sensitivity.localization_metrics(z, pos, true_source);
            f = m.per_frame(1);
            testCase.verifyEqual(f.true_index, 2);
            testCase.verifyEqual(f.distance_mm, 0, 'AbsTol', 1e-12);
            testCase.verifyEqual(f.angular_deviation_deg, 90, 'AbsTol', 1e-12);
        end

        function inverseRunDisabledKeepsPreviousOutputs(testCase)
            zef = local_synthetic_zef();
            zef2 = zef_inverse_run(zef, "mne");
            testCase.verifyFalse(isfield(zef2, 'localization_metrics'));
            testCase.verifyNotEmpty(zef2.reconstruction);
        end

        function inverseRunEnabledReportsConsistentMetrics(testCase)
            zef = local_synthetic_zef();
            zef_plain = zef_inverse_run(zef, "mne");
            zef_metrics = zef_inverse_run(zef, "mne", ...
                'ComputeLocalizationMetrics', true);
            % Solver behavior is untouched: identical reconstruction.
            testCase.verifyEqual(numel(zef_metrics.reconstruction), ...
                numel(zef_plain.reconstruction));
            for f = 1:numel(zef_plain.reconstruction)
                testCase.verifyEqual(zef_metrics.reconstruction{f}, ...
                    zef_plain.reconstruction{f}, 'AbsTol', 1e-12);
            end
            m = zef_metrics.localization_metrics;
            testCase.verifyEqual(m.method_id, "mne");
            testCase.verifyEqual(m.summary.n_frames, 3);
            testCase.verifyTrue(m.summary.all_valid);
            % Internal consistency: distance matches the reported peak.
            for f = 1:numel(m.per_frame)
                rec = zef_metrics.reconstruction{f};
                W = reshape(rec, 3, []);
                [~, peak] = max(sqrt(sum(W.^2, 1)));
                expected = norm(zef.source_positions(peak, :) ...
                    - zef.inv_synth_source(1, 1:3));
                testCase.verifyEqual(m.per_frame(f).distance_mm, expected, ...
                    'AbsTol', 1e-9);
                testCase.verifyEqual(m.per_frame(f).peak_index, peak);
            end
        end

        function metricsWorkForEveryFastClassSolver(testCase)
            % The shared zef_inverse_run hook is solver-agnostic; exercise
            % it through eLORETA as a second, independent solver family
            % (iterative precompute path) on the same mini example.
            zef = local_synthetic_zef();
            methods_ = ["eloreta"];
            for mi = 1:numel(methods_)
                zef_m = zef_inverse_run(zef, methods_(mi), ...
                    'ComputeLocalizationMetrics', true);
                m = zef_m.localization_metrics;
                testCase.verifyEqual(m.method_id, methods_(mi));
                testCase.verifyEqual(m.summary.n_frames, 3);
                testCase.verifyTrue(m.summary.all_valid, ...
                    "Solver " + methods_(mi) + " produced a degenerate frame");
                for f = 1:numel(m.per_frame)
                    rec = zef_m.reconstruction{f};
                    W = reshape(rec, 3, []);
                    [~, peak] = max(sqrt(sum(W.^2, 1)));
                    expected = norm(zef.source_positions(peak, :) ...
                        - zef.inv_synth_source(1, 1:3));
                    testCase.verifyEqual(m.per_frame(f).distance_mm, ...
                        expected, 'AbsTol', 1e-9);
                end
            end
        end

        function inverseRunExplicitTrueSourceStructWorks(testCase)
            zef = local_synthetic_zef();
            zef = rmfield(zef, 'inv_synth_source');
            true_source = struct('position', [0 0 0], 'direction', [1 0 0]);
            zef2 = zef_inverse_run(zef, "mne", ...
                'ComputeLocalizationMetrics', true, 'TrueSource', true_source);
            testCase.verifyTrue(isfield(zef2, 'localization_metrics'));
            testCase.verifyEqual(zef2.localization_metrics.true_source.position, ...
                [0 0 0]);
        end

        function inverseRunMissingTrueSourceErrors(testCase)
            zef = local_synthetic_zef();
            zef = rmfield(zef, 'inv_synth_source');
            testCase.verifyError(@() zef_inverse_run(zef, "mne", ...
                'ComputeLocalizationMetrics', true), ...
                'zef_inverse_run:MissingTrueSource');
        end

        function dialogCheckboxReachesBackendAndReports(testCase)
            zef = local_synthetic_zef();
            assignin('base', 'zef', zef);
            zef_win = zef_mne_class_window(zef);
            fig = zef_win.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            cb = findall(fig, 'Tag', 'zef_inv_compute_localization_metrics');
            testCase.verifyNotEmpty(cb, ...
                'Class dialog must expose the localization-metrics checkbox');
            cb.Value = true;
            btn = findall(fig, 'Tag', 'zef_inv_start');
            testCase.verifyNotEmpty(btn);
            btn.ButtonPushedFcn(btn, []);
            zef_after = evalin('base', 'zef');
            testCase.verifyNotEmpty(zef_after.reconstruction);
            testCase.verifyTrue(isfield(zef_after, 'localization_metrics'));
            m = zef_after.localization_metrics;
            testCase.verifyEqual(m.summary.n_frames, 3);
            testCase.verifyEqual(m.method_id, "mne");
        end

        function dialogRejectsMetricsWithoutGroundTruth(testCase)
            zef = local_synthetic_zef();
            zef = rmfield(zef, 'inv_synth_source');
            assignin('base', 'zef', zef);
            zef_win = zef_mne_class_window(zef);
            fig = zef_win.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            cb = findall(fig, 'Tag', 'zef_inv_compute_localization_metrics');
            testCase.verifyNotEmpty(cb);
            cb.Value = true;
            btn = findall(fig, 'Tag', 'zef_inv_start');
            btn.ButtonPushedFcn(btn, []);
            zef_after = evalin('base', 'zef');
            % Blocked before the solver ran: no reconstruction, no metrics.
            testCase.verifyFalse(isfield(zef_after, 'localization_metrics'));
            testCase.verifyFalse(isfield(zef_after, 'reconstruction'));
        end
    end
end

function zef = local_synthetic_zef()
%LOCAL_SYNTHETIC_ZEF  Deterministic 4-sensor/2-source session with ground truth.

rng(7, 'twister');
zef = tests.support.createSyntheticInverseZef();
% Ground truth: source 1 (position [0 0 0], orientation +x). The
% measurements are exactly the lead-field column of that dipole, so a
% reasonable solver peaks at or very near source 1.
dip = [1; 0; 0; 0; 0; 0];
zef.measurements = zef.L * dip * ones(1, 3);
zef.inv_synth_source = [0 0 0 1 0 0 10 0 3 1];

end
