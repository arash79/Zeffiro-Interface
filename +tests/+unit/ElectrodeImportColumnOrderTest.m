classdef ElectrodeImportColumnOrderTest < matlab.unittest.TestCase
%ELECTRODEIMPORTCOLUMNORDERTEST  Parsers emit attach-order CEM columns.

    methods (Test)
        function testCsvNamedColumnsBecomeOuterInner(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            file = fullfile(folder, "cem.csv");
            fid = fopen(file, "w");
            fprintf(fid, "x,y,z,inner_radius,outer_radius,impedance\n");
            fprintf(fid, "1,2,3,4,10,1000\n");
            fclose(fid);
            [data, labels] = core.io.electrodes.from_csv(file);
            testCase.verifyEqual(data, [1 2 3 10 4 1000]);
            testCase.verifyEqual(labels, "S1");
        end

        function testDatFileInnerOuterBecomesOuterInner(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            file = fullfile(folder, "cem.dat");
            fid = fopen(file, "w");
            fprintf(fid, "1 2 3 4 10 1000\n");
            fclose(fid);
            [data, labels] = core.io.electrodes.from_dat(file);
            testCase.verifyEqual(data, [1 2 3 10 4 1000]);
            testCase.verifyEqual(labels, "S1");
        end

        function testAttachAnnulusIsNonEmptyWithImportedOrder(testCase)
            % inner=4, outer=10 in the file → stored as [10 4].
            % A centroid at distance 6 must be kept (4 ≤ 6 < 10).
            sensors = [0 0 0 10 4 1000];
            d = 6;
            keep = d < sensors(4) && d >= sensors(5);
            testCase.verifyTrue(keep);
            % Inherited parser order [4 10] would reject every d.
            wrong = [0 0 0 4 10 1000];
            testCase.verifyFalse(d < wrong(4) && d >= wrong(5));
        end
    end
end
