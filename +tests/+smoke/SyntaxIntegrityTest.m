classdef SyntaxIntegrityTest < matlab.unittest.TestCase
%SYNTAXINTEGRITYTEST  Every shipped .m file must be parseable by MATLAB.
%
%   A file that does not parse throws the instant anything reaches it, so a
%   single stray character can silently disable a menu item or plot callback
%   that no other test exercises. checkcode is used rather than a runtime
%   call because it needs neither a MATLAB path entry nor a resolvable
%   function name, so scripts, class files and plugin helpers are all
%   covered. The first two tests pin the checkcode parse-error ids this
%   class relies on.
%
%   See also tests.smoke.ArchitectureLayoutTest.

    properties (Constant)
        % checkcode ids that mean "MATLAB cannot parse this", as opposed to
        % the style and lint ids that make up the rest of its output.
        ParseErrorIds = {'SYNER', 'BADCH', 'MDOTM', 'EOLPAR'}
    end

    methods (Test)
        function detectorRecognisesBrokenSyntax(testCase)
            % Guard the guard: if checkcode stopped reporting these ids the
            % sweep below would pass on a repository full of broken files.
            probes = { ...
                'orphan_paren', sprintf('function y=orphan_paren(x)\ny=abs(x\n);\nend\n'); ...
                'surplus_end',  sprintf('function y=surplus_end(x)\ny=x;\nend\nend\n'); ...
                'lost_comment', sprintf('function y=lost_comment(x)\nnse.time: 1 -> 2\ny=x;\nend\n')};

            scratch = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);

            for i = 1:size(probes, 1)
                target = fullfile(scratch.Folder, [probes{i, 1} '.m']);
                fid = fopen(target, 'w');
                testCase.assertNotEqual(fid, -1, "could not write " + target);
                fwrite(fid, probes{i, 2});
                fclose(fid);

                testCase.verifyTrue(testCase.hasParseError(target), ...
                    "checkcode no longer reports a parse error for the " + ...
                    probes{i, 1} + " probe, so the repository sweep in this " + ...
                    "class cannot be trusted");
            end
        end

        function detectorAcceptsValidSyntax(testCase)
            scratch = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            target = fullfile(scratch.Folder, 'well_formed.m');
            fid = fopen(target, 'w');
            testCase.assertNotEqual(fid, -1);
            fwrite(fid, sprintf('function y = well_formed(x)\n%% Doc line.\ny = abs(x);\nend\n'));
            fclose(fid);

            testCase.verifyFalse(testCase.hasParseError(target), ...
                'checkcode reports a parse error for a well-formed file');
        end

        function everyRepositoryFileParses(testCase)
            root = fileparts(which('zeffiro_interface'));
            testCase.assumeNotEmpty(root, 'zeffiro_interface is not on the MATLAB path');

            files = tests.smoke.SyntaxIntegrityTest.repositorySources(root);
            testCase.assertNotEmpty(files, 'found no .m files to check');

            broken = strings(0, 1);
            for i = 1:numel(files)
                [failed, detail] = testCase.hasParseError(files{i});
                if failed
                    broken(end+1) = erase(string(files{i}), string(root) + filesep) + ...
                        " -> " + detail; %#ok<AGROW>
                end
            end

            testCase.verifyEmpty(broken, ...
                "these files do not parse and will throw when reached:" + ...
                newline + strjoin(broken, newline));
        end
    end

    methods (Access = private)
        function [failed, detail] = hasParseError(testCase, file)
            messages = checkcode(file, '-id', '-struct');
            failed = false;
            detail = "";
            for i = 1:numel(messages)
                if ismember(messages(i).id, testCase.ParseErrorIds)
                    failed = true;
                    detail = detail + sprintf('[%s line %d] %s ', ...
                        messages(i).id, messages(i).line, messages(i).message);
                end
            end
            detail = strtrim(detail);
        end
    end

    methods (Static, Access = private)
        function files = repositorySources(root)
            % external/ holds third-party sources this project does not own.
            listing = dir(fullfile(root, '**', '*.m'));
            keep = ~contains({listing.folder}, [filesep '.git']) ...
                 & ~contains({listing.folder}, [filesep 'external']);
            listing = listing(keep);
            files = fullfile({listing.folder}, {listing.name});
        end
    end
end
