classdef LeadFieldSensorsAuxTest < matlab.unittest.TestCase
%LEADFIELDSENSORSAUTEST  Types 1–10 mm→m vs CEM index table.

    methods (Test)
        function testPemEegFamilyDividesAttachedXyz(testCase)
            sensors = [10 20 30; 40 50 60];
            attached = [100 200 300; 400 500 600];
            for t = [1, 4, 5, 6, 9, 10]
                out = zef_lead_field_sensors_aux(t, sensors, attached);
                testCase.verifyEqual(out, attached / 1000, "AbsTol", 1e-15);
            end
        end

        function testMegFamilyScalesSensorsNotAttachment(testCase)
            sensors = [10 20 30 0 0 1; 40 50 60 1 0 0];
            attached = zeros(0, 4);
            for t = [2, 3, 7, 8]
                out = zef_lead_field_sensors_aux(t, sensors, attached);
                testCase.verifyEqual(out(:, 1:3), sensors(:, 1:3) / 1000, "AbsTol", 1e-15);
                testCase.verifyEqual(out(:, 4:6), sensors(:, 4:6));
            end
        end

        function testCemPassesAttachmentUnscaled(testCase)
            sensors = [1 2 3 4 5 6];
            attached = [1 10 11 12; 2 13 14 15];
            for t = [1, 4, 5, 6, 9, 10]
                out = zef_lead_field_sensors_aux(t, sensors, attached);
                testCase.verifyEqual(out, attached);
            end
        end

        function testAnisotropicMegDoesNotUseEegTable(testCase)
            testCase.verifyError(@() zef_lead_field_sensors_aux(7, [], [1 2 3 4]), ...
                "zef_lead_field_sensors_aux:MissingMEGSensors");
        end
    end
end
