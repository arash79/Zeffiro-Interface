classdef PluginIniResolutionTest < matlab.unittest.TestCase
%PLUGININIRESOLUTIONTEST  Default-profile Start functions exist on the path.

    methods (Test)
        function testMulticompartmentHeadStartFunctionsResolve(testCase)
            ini = fullfile(fileparts(which("zeffiro_interface")), ...
                "profile", "multicompartment_head", "zeffiro_plugins.ini");
            testCase.assumeTrue(isfile(ini));
            lines = readlines(ini);
            missing = strings(0, 1);
            for k = 1:numel(lines)
                line = strtrim(lines(k));
                if line == "" || startsWith(line, "#") || startsWith(line, "%")
                    continue
                end
                parts = split(line, ",");
                if numel(parts) < 3
                    continue
                end
                fn = strtrim(parts(end));
                if isempty(which(fn))
                    missing(end+1, 1) = fn; %#ok<AGROW>
                end
            end
            testCase.verifyEmpty(missing, ...
                "Unresolved plugin Start functions: " + strjoin(missing, ", "));
        end
    end
end
