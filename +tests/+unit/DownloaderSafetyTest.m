classdef DownloaderSafetyTest < matlab.unittest.TestCase
%DOWNLOADERSAFETYTEST  zeffiro_downloader quotes git args and rejects non-URLs.

    methods (Test)
        function testSourceContainsShellQuotingHelpers(testCase)
            % Structural: quoting helper names and cwd onCleanup stay in source.
            src = fileread(which("zeffiro_downloader"));
            testCase.verifyTrue(contains(src, "i_shell_quote(kwargs.branch_name)"));
            testCase.verifyTrue(contains(src, "i_shell_quote(kwargs.git_address)"));
            testCase.verifyTrue(contains(src, "i_shell_quote(program_path)"));
            testCase.verifyTrue(contains(src, "onCleanup"));
            testCase.verifyTrue(contains(src, "InvalidGitAddress"));
        end

        function testRejectsNonUrlGitAddress(testCase)
            testCase.verifyError( ...
                @() zeffiro_downloader( ...
                    "install_directory", tempdir, ...
                    "run_setup", false, ...
                    "git_address", "not a url; rm -rf /"), ...
                "zeffiro_downloader:InvalidGitAddress");
        end
    end
end
