classdef UpstreamPortRegressionTest < matlab.unittest.TestCase
%UPSTREAMPORTREGRESSIONTEST  File-level guards for ports from 9dd0f036..upstream.

    methods (Test)
        function testKalmanBurnInUsesNum2str(testCase)
            src = fileread(fullfile("plugins", "Kalman", "m", "zef_kf_open_window.m"));
            testCase.verifyFalse(contains(src, "mun2str"));
            testCase.verifyTrue(contains(src, "num2str(zef.kf_burn_in)"));
        end

        function testDefaultHeadIniRegistersNewForwardTools(testCase)
            ini = fileread(fullfile("profile", "multicompartment_head", "zeffiro_plugins.ini"));
            testCase.verifyTrue(contains(ini, "zef_strip_tool_start"));
            testCase.verifyTrue(contains(ini, "zef_start_source_tree_tool"));
            testCase.verifyTrue(contains(ini, "zef_find_synthetic_source_ROI"));
            testCase.verifyTrue(contains(ini, "zef_find_synthetic_source_patch"));
            testCase.verifyEqual(numel(strfind(ini, "zef_strip_tool_start")), 1);
        end

        function testPatchPluginWasNotDeleted(testCase)
            testCase.verifyTrue(isfile(fullfile( ...
                "plugins", "FindSyntheticSourceLegacy_Patch", ...
                "zef_find_source_patch.m")));
            testCase.verifyFalse(isfile(fullfile( ...
                "plugins", "FindSyntheticSourceROI", ...
                "plotting_tools", "zef_plot_sphere.m")));
        end
    end
end
