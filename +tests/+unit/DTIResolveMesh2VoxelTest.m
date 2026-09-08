classdef DTIResolveMesh2VoxelTest < matlab.unittest.TestCase
%DTIRESOLVEMESH2VOXELTEST  register.dat without orig.mgz must not mix RAS frames.

    methods (Test)
        function registerWithoutReferenceErrors(testCase)
            zef = struct();
            zef.freesurfer_register_transform = eye(4);
            testCase.verifyError(@() zef_dti_resolve_mesh2voxel(zef), ...
                "Zeffiro:DTI:IncompleteFreeSurferChain");
        end

        function niftiOnlyWithoutRegisterReturnsEmpty(testCase)
            zef = struct();
            T = zef_dti_resolve_mesh2voxel(zef);
            testCase.verifyEmpty(T);
        end

        function applyNoLongerSwallowsMesh2VoxelErrors(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            src = fileread(fullfile(root, "src", "forward", "dti", ...
                "zef_dti_apply_to_sigma.m"));
            testCase.verifyTrue(contains(src, "zef_dti_resolve_mesh2voxel"));
            testCase.verifyFalse(contains(src, "T_mesh2voxel = [];"));
        end
    end
end
