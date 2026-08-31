classdef EegFaceBasedDirectionModeTest < matlab.unittest.TestCase
%EEGFACEBASEDDIRECTIONMODETEST  EEG face_based / mesh-based must error, not skip L.

    methods (Test)
        function testSourceContainsExplicitError(testCase)
            src = fileread(fullfile("src", "forward", "lead_field", "zef_lead_field_eeg_fem.m"));
            testCase.verifyTrue(contains(src, "zef_lead_field_eeg_fem:UnsupportedDirectionMode"));
            testCase.verifyTrue(contains(src, "face_based is not implemented"));
        end
    end
end
