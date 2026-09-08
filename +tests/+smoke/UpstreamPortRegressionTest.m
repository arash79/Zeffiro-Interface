classdef UpstreamPortRegressionTest < matlab.unittest.TestCase
%UPSTREAMPORTREGRESSIONTEST  Kalman burn-in formatting and default-profile tools.

    methods (Test)
        function testKalmanBurnInUsesNum2str(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            src = fileread(fullfile(root, "plugins", "Kalman", "m", "zef_kf_open_window.m"));
            testCase.verifyFalse(contains(src, "mun2str"));
            testCase.verifyTrue(contains(src, "num2str(zef.kf_burn_in)"));
        end

        function testDefaultHeadIniRegistersForwardTools(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            ini = fileread(fullfile(root, "profile", "multicompartment_head", "zeffiro_plugins.ini"));
            testCase.verifyTrue(contains(ini, "zef_strip_tool_start"));
            testCase.verifyTrue(contains(ini, "zef_start_source_tree_tool"));
            testCase.verifyTrue(contains(ini, "zef_find_synthetic_source_ROI"));
            testCase.verifyTrue(contains(ini, "zef_find_synthetic_source_patch"));
            testCase.verifyEqual(numel(strfind(ini, "zef_strip_tool_start")), 1);
        end
    end
end
