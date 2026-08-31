classdef DownloaderSafetyTest < matlab.unittest.TestCase
%DOWNLOADERSAFETYTEST  zeffiro_downloader must quote git args and restore cwd.

    methods (Test)
        function testSourceQuotesArgsAndRestoresCwd(testCase)
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

        function testPosixQuoteLeavesMetacharactersLiteral(testCase)
            testCase.assumeFalse(ispc, "POSIX quoting contract");
            quoted = i_posix_quote("master; echo pwned");
            testCase.verifyEqual(quoted, '''master; echo pwned''');
            quoted_space = i_posix_quote("/tmp/my project/zeffiro");
            testCase.verifyEqual(quoted_space, '''/tmp/my project/zeffiro''');
            quoted_sq = i_posix_quote("it's");
            expected_sq = ['''' 'it' '''' '\' '''' '''' 's' ''''];
            testCase.verifyEqual(quoted_sq, expected_sq);
        end
    end
end

function q = i_posix_quote(s)
s = char(string(s));
q = ['''' strrep(s, '''', '''\''''') ''''];
end
