function cluster_profile = configure_cluster_profile(computing_project, opts)
% --- Zeffiro documentation header ---
% utilities.cluster.configure_cluster_profile — Configure cluster profile.
%
% Purpose:
%   Configure cluster profile.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   computing_project
%   opts
%
% Outputs:
%   cluster_profile
%
% Calls (project):
%   utilities.cluster.configure_cluster_profile
%
% Side effects:
%   - parallel/cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[cluster_profile] = utilities.cluster.configure_cluster_profile(computing_project, opts)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%CONFIGURE_CLUSTER_PROFILE Configure a CSC Puhti cluster profile.
%
% This utility configures MATLAB's current cluster profile so that the
% AdditionalProperties names match the CSC/MathWorks SLURM integration
% scripts. In particular, the required properties are:
%   - ComputingProject
%   - MemPerCPU
%   - WallTime
%
% Prerequisite:
%   Run CSC's `configCluster` first so `parcluster` points to the Puhti
%   Generic profile.

arguments
    computing_project (1,1) string {mustBeNonempty}
    opts.MemPerCPU (1,1) string {mustBeNonempty} = "4g"
    opts.WallTime (1,1) string {mustBeNonempty} = "24:00:00"
    opts.Partition (1,1) string = ""
    opts.CPUsPerNode (1,1) double {mustBeInteger, mustBeNonnegative} = 0
    opts.ProcsPerNode (1,1) double {mustBeInteger, mustBeNonnegative} = 0
    opts.GPUsPerNode (1,1) double {mustBeInteger, mustBeNonnegative} = 0
    opts.GPUCard (1,1) string = ""
    opts.Constraint (1,1) string = ""
    opts.Reservation (1,1) string = ""
    opts.RequireExclusiveNode (1,1) logical = false
    opts.LocalStorageSpacePerNode (1,1) string = ""
    opts.EmailAddress (1,1) string = ""
    opts.AdditionalSubmitArgs (1,1) string = ""
    opts.NumThreads (1,1) double {mustBeInteger, mustBePositive} = 1
    opts.ProfileName (1,1) string {mustBeNonempty} = "CSCPuhti"
end

cluster_profile = parcluster;

ap = cluster_profile.AdditionalProperties;
ap.ComputingProject = char(computing_project);
ap.MemPerCPU = char(opts.MemPerCPU);
ap.WallTime = char(opts.WallTime);

% Optional scheduler properties supported by CSC integration scripts.
if opts.Partition ~= ""
    ap.Partition = char(opts.Partition);
end
if opts.CPUsPerNode > 0
    ap.CPUsPerNode = opts.CPUsPerNode;
end
if opts.ProcsPerNode > 0
    ap.ProcsPerNode = opts.ProcsPerNode;
end
if opts.GPUsPerNode > 0
    ap.GPUsPerNode = opts.GPUsPerNode;
end
if opts.GPUCard ~= ""
    ap.GPUCard = char(opts.GPUCard);
end
if opts.Constraint ~= ""
    ap.Constraint = char(opts.Constraint);
end
if opts.Reservation ~= ""
    ap.Reservation = char(opts.Reservation);
end
if opts.RequireExclusiveNode
    ap.RequireExclusiveNode = true;
end
if opts.LocalStorageSpacePerNode ~= ""
    ap.LocalStorageSpacePerNode = char(opts.LocalStorageSpacePerNode);
end
if opts.EmailAddress ~= ""
    ap.EmailAddress = char(opts.EmailAddress);
end
if opts.AdditionalSubmitArgs ~= ""
    ap.AdditionalSubmitArgs = char(opts.AdditionalSubmitArgs);
end

cluster_profile.NumThreads = opts.NumThreads;
cluster_profile.saveProfile(char(opts.ProfileName));

fprintf('Cluster profile "%s" configured and saved.\n', char(opts.ProfileName));
fprintf('  ComputingProject: %s\n', char(computing_project));
fprintf('  MemPerCPU: %s\n', char(opts.MemPerCPU));
fprintf('  WallTime: %s\n', char(opts.WallTime));
fprintf('  NumThreads: %d\n', opts.NumThreads);
if opts.Partition ~= ""
    fprintf('  Partition: %s\n', char(opts.Partition));
end
if opts.GPUsPerNode > 0
    fprintf('  GPUsPerNode: %d\n', opts.GPUsPerNode);
end

end
