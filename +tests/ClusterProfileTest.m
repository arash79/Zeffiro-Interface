classdef ClusterProfileTest < matlab.unittest.TestCase
%CLUSTERPROFILETEST  configure_cluster_profile writes CSC AdditionalProperties.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Skips unless parcluster has AdditionalProperties.ComputingProject
%   (CSC generic profile). Then asserts configure_cluster_profile sets
%   the project name (and related fields in this file).
%

    methods (Test)
        function testConfigureClusterProfileSetsCscFields(testCase)
            c = parcluster;
            testCase.assumeTrue(isprop(c.AdditionalProperties, 'ComputingProject'), ...
                'CSC Generic profile is not active in this environment.');

            c = utilities.cluster.configure_cluster_profile( ...
                "project_test", ...
                "MemPerCPU", "8g", ...
                "WallTime", "00:10:00", ...
                "Partition", "test", ...
                "NumThreads", 1 ...
            );

            testCase.verifyEqual(string(c.AdditionalProperties.ComputingProject), "project_test");
            testCase.verifyEqual(string(c.AdditionalProperties.MemPerCPU), "8g");
            testCase.verifyEqual(string(c.AdditionalProperties.WallTime), "00:10:00");
        end
    end

end
