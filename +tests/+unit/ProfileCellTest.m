classdef ProfileCellTest < matlab.unittest.TestCase
%PROFILECELLTEST  zef_read_profile_cell matches readcell on profile INIs.

    methods (Test)

        function defaultProfileFilesMatchReadcell(testCase)
            root = fileparts(which('zeffiro_interface'));
            testCase.assumeNotEmpty(root, 'zeffiro_interface is not on the MATLAB path');
            files = { ...
                fullfile(root, 'profile', 'zeffiro_interface.ini'); ...
                fullfile(root, 'profile', 'multicompartment_head', 'zeffiro_plugins.ini'); ...
                fullfile(root, 'profile', 'multicompartment_head', 'zeffiro_parameters.ini'); ...
                fullfile(root, 'profile', 'multicompartment_head', 'zeffiro_init.ini'); ...
                fullfile(root, 'profile', 'multicompartment_head', 'zeffiro_segmentation.ini'); ...
                fullfile(root, 'profile', 'multicompartment_head', 'zeffiro_forward_simulation.ini')};
            for i = 1:numel(files)
                p = files{i};
                testCase.assumeTrue(isfile(p), p);
                got = zef_read_profile_cell(p);
                exp = readcell(p, 'FileType', 'text');
                local_assert_equiv(testCase, got, exp, p);
            end
        end

        function quotedCommaFieldIsPreserved(testCase)
            f = [tempname '.ini'];
            testCase.addTeardown(@() local_delete_file(f));
            fid = fopen(f, 'w');
            fprintf(fid, '"Hello, world",1,lab,string\n');
            fprintf(fid, 'plain,2,other,number\n');
            fclose(fid);
            C = zef_read_profile_cell(f);
            testCase.verifyEqual(C{1, 1}, 'Hello, world');
            testCase.verifyEqual(C{1, 2}, 1);
            testCase.verifyEqual(C{2, 1}, 'plain');
            testCase.verifyEqual(C{2, 2}, 2);
        end

        function cacheInvalidatesWhenFileBytesChange(testCase)
            f = [tempname '.ini'];
            testCase.addTeardown(@() local_delete_file(f));
            fid = fopen(f, 'w');
            fprintf(fid, 'A,1,x,number\n');
            fclose(fid);
            C1 = zef_read_profile_cell(f);
            testCase.verifyEqual(C1{1, 1}, 'A');
            fid = fopen(f, 'w');
            fprintf(fid, 'BB,2,y,number\n');
            fclose(fid);
            C2 = zef_read_profile_cell(f);
            testCase.verifyEqual(C2{1, 1}, 'BB');
            testCase.verifyEqual(C2{1, 2}, 2);
        end

        function bracketedNumberVectorStaysText(testCase)
            f = [tempname '.ini'];
            testCase.addTeardown(@() local_delete_file(f));
            fid = fopen(f, 'w');
            fprintf(fid, 'pos,[0 0 0 0],segmentation_tool_default_position,number\n');
            fclose(fid);
            C = zef_read_profile_cell(f);
            testCase.verifyEqual(C{1, 2}, '[0 0 0 0]');
        end

    end
end

function local_assert_equiv(testCase, got, exp, label)

testCase.verifyEqual(size(got), size(exp), label);
for i = 1:numel(got)
    testCase.verifyEqual(local_norm(got{i}), local_norm(exp{i}), ...
        sprintf('%s cell %d', label, i));
end

end

function v = local_norm(v)

if isa(v, 'missing') || (isstring(v) && isscalar(v) && ismissing(v))
    v = [];
    return
end
if isstring(v)
    v = char(v);
end

end

function local_delete_file(f)

if exist(f, 'file') == 2
    delete(f);
end

end
