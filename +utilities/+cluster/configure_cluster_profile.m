function cluster_profile = configure_cluster_profile(computing_project, opts)
%CONFIGURE_CLUSTER_PROFILE  Set CSC Puhti SLURM properties on a cluster profile.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   cluster_profile = configure_cluster_profile(computing_project, opts)
%
%   Configures parcluster AdditionalProperties for CSC/MathWorks Puhti integration:
%   ComputingProject, MemPerCPU (default "4g"), WallTime (default "24:00:00"),
%   and optional Partition, CPUsPerNode, GPUsPerNode, GPUCard, Constraint,
%   Reservation, RequireExclusiveNode, LocalStorageSpacePerNode, EmailAddress,
%   AdditionalSubmitArgs. Sets NumThreads (default 1) and saves under
%   opts.ProfileName (default "CSCPuhti").
%
%   Prerequisite: run CSC configCluster so parcluster points at the Puhti profile.

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
