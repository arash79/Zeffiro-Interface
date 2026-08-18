classdef FindSyntheticSourceROITest < matlab.unittest.TestCase
%FINDSYNTHETICSOURCEROITEST  Headless ROI membership, forward product, polar ellipsoid.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(7, "twister");
        end
    end

    methods (Test)
        function testSphericalROISelectsInteriorPoints(testCase)
            P = [0 0 0; 1 0 0; 0 1 0; 5 0 0; 0 0 5];
            specs = struct("shape", 2, "radius", 1.1, "roi_center", [0 0 0]);
            [s_roi, specs_out] = zef_ROI_finder(P, specs);
            testCase.verifyEqual(sort(s_roi(:))', [1 2 3]);
            testCase.verifyEqual(specs_out.roi_center, [0 0 0]);
        end

        function testEmptySphereSnapsToNearestSource(testCase)
            P = [10 0 0; 20 0 0];
            specs = struct("shape", 2, "radius", 0.1, "roi_center", [0 0 0]);
            [s_roi, specs_out] = zef_ROI_finder(P, specs);
            testCase.verifyEqual(s_roi, 1);
            testCase.verifyEqual(specs_out.roi_center, [10 0 0]);
        end

        function testFlatDiskAlongZ(testCase)
            [X, Y, Z] = ndgrid(-2:2, -2:2, -1:1);
            P = [X(:), Y(:), Z(:)];
            specs = struct( ...
                "shape", 1, ...
                "radius", 1.1, ...
                "width", 0.2, ...
                "curvature", 0, ...
                "oriType", 1, ...
                "ori", [0 0 1], ...
                "roi_center", [0 0 0]);
            s_roi = zef_ROI_finder(P, specs);
            selected = P(s_roi, :);
            testCase.verifyTrue(all(abs(selected(:, 3)) <= 0.2 + 1e-12));
            testCase.verifyTrue(all(hypot(selected(:, 1), selected(:, 2)) <= 1.1 + 1e-12));
            testCase.verifyGreaterThan(numel(s_roi), 1);
        end

        function testFindSourceROISphericalMeasurementsFinite(testCase)
            zef = struct();
            zef.source_positions = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 4 0 0];
            n_src = size(zef.source_positions, 1);
            zef.L = randn(5, 3*n_src);
            % shape 2 (sphere), radius 1.2, centre origin, custom dipole ori +x
            zef.synth_source_ROI = [2 1.2 0 0 1 1 0 0  0 0 0  1 1 0 0  10 0 1 1 3];
            meas = zef_find_source_ROI(zef);
            testCase.verifySize(meas, [size(zef.L, 1), 1]);
            testCase.verifyTrue(all(isfinite(meas)));
            testCase.verifyGreaterThan(norm(meas), 0);
        end

        function testPlotEllipsoidPolarAxisDoesNotError(testCase)
            f = figure("Visible", "off", "WindowStyle", "normal");
            testCase.addTeardown(@() close(f));
            h = zef_plot_ellipsoid([0 0 0], 1, 1, 2, [0 0 1], [1 0 0]);
            testCase.verifyTrue(ishandle(h));
            testCase.verifyTrue(all(isfinite(h.XData(:))));
            testCase.verifyTrue(all(isfinite(h.YData(:))));
            testCase.verifyTrue(all(isfinite(h.ZData(:))));
        end
    end
end
