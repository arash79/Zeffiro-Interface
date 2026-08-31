classdef ZefSourceModelLoadTest < matlab.unittest.TestCase
%ZEFSOURCEMODELLOADTEST  Legacy core.ZefSourceModel enumerations load without warnings.

    methods (Test)

        function fromAcceptsMemberNamesAndLegacyEnum(testCase)
            testCase.verifyEqual( ...
                core.types.ZefSourceModel.from('Hdiv'), ...
                core.types.ZefSourceModel.Hdiv);
            testCase.verifyEqual( ...
                core.types.ZefSourceModel.from('Whitney'), ...
                core.types.ZefSourceModel.Whitney);
            testCase.verifyEqual( ...
                core.types.ZefSourceModel.from(2), ...
                core.types.ZefSourceModel.Hdiv);
            testCase.verifyEqual( ...
                core.types.ZefSourceModel.from(core.ZefSourceModel.StVenant), ...
                core.types.ZefSourceModel.StVenant);
            s = struct('ValueNames', 'ContinuousHdiv');
            testCase.verifyEqual( ...
                core.types.ZefSourceModel.from(s), ...
                core.types.ZefSourceModel.ContinuousHdiv);
        end

        function savedLegacyEnumLoadsWithoutWarning(testCase)
            testCase.assumeTrue(isenum(core.ZefSourceModel.Hdiv), ...
                'core.ZefSourceModel must be an enumeration so MATLAB can load old projects.');
            f = [tempname '.mat'];
            testCase.addTeardown(@() local_delete(f));
            source_model = core.ZefSourceModel.Whitney; %#ok<NASGU>
            save(f, 'source_model');
            testCase.verifyWarningFree(@() local_whos(f));
            loaded = testCase.verifyWarningFree(@() load(f, 'source_model'));
            converted = core.types.ZefSourceModel.from(loaded.source_model);
            testCase.verifyEqual(converted, core.types.ZefSourceModel.Whitney);
        end

    end

end

function local_whos(f)
w = whos('-file', f); %#ok<NASGU>
end

function local_delete(f)
if exist(f, 'file')
    delete(f);
end
end
