classdef SourceTreeJRTest < matlab.unittest.TestCase
%SOURCETREEJRTEST  Headless Jansen–Rit tree simulation (no App Designer window).

    methods (TestMethodSetup)
        function seedRng(~)
            rng(11, "twister");
        end
    end

    methods (Test)
        function testSingleNodeSimulationIsFinite(testCase)
            tree.Root = struct("Text", "Root", "NodeData", zef_init_jr_nodedata());
            gd = zef_init_signal_general_data();
            gd.blockDuration_s.Value = 0.04;
            gd.samplingRate_Hz.Value = 250;
            gd.gaussianNoiseStd.Value = 0;
            out = zef_simulate_jr_tree(tree, gd);
            testCase.verifyTrue(isfield(out.Root, "upRaw"));
            testCase.verifyTrue(all(isfinite(out.Root.upRaw(:))));
            testCase.verifyEqual(size(out.Root.upRaw, 1), floor(0.04*250) + 1);
            testCase.verifyGreaterThan(max(abs(out.Root.upRaw(:))), 0);
        end

        function testSourceNoiseStdFieldIsHonored(testCase)
            nd = zef_init_jr_nodedata();
            nd.SourceNoiseStd.Value = 0.5;
            tree.Root = struct("Text", "Root", "NodeData", nd);
            gd = zef_init_signal_general_data();
            gd.blockDuration_s.Value = 0.04;
            gd.samplingRate_Hz.Value = 250;
            out = zef_simulate_jr_tree(tree, gd);
            testCase.verifyTrue(all(isfinite(out.Root.upRaw(:))));
        end
    end
end
