classdef PluginIniResolutionTest < matlab.unittest.TestCase
%PLUGININIRESOLUTIONTEST  Every profile's Start functions exist on the path.

    methods (Test)
        function testEveryProfileStartFunctionResolves(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            profile_root = fullfile(root, "profile");
            listing = dir(profile_root);
            profiles = string({listing([listing.isdir]).name});
            profiles = profiles(~ismember(profiles, [".", ".."]));
            testCase.assumeNotEmpty(profiles, "no profile folders found");

            missing = strings(0, 1);
            for p = profiles(:)'
                ini = fullfile(profile_root, p, "zeffiro_plugins.ini");
                if ~isfile(ini)
                    continue
                end
                lines = readlines(ini);
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
                        missing(end+1, 1) = p + "/" + fn; %#ok<AGROW>
                    end
                end
            end
            testCase.verifyEmpty(missing, ...
                "Unresolved plugin Start functions: " + strjoin(missing, ", "));
        end
    end
end
