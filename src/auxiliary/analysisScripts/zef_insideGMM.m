function [list] = zef_insideGMM(GMM, points, numberOfModels)
% --- Zeffiro documentation header ---
% zef_insideGMM — Zef inside GMM.
%
% Purpose:
%   Zef inside GMM.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   GMM
%   points
%   numberOfModels
%
% Outputs:
%   list
%
% Calls (project):
%   zef_insideGMM
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[list] = zef_insideGMM(GMM, points, numberOfModels)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin==2
    numberOfModels=1;
end

if size(GMM.model.Sigma, 3)<numberOfModels
    numberOfModels=size(GMM.model.Sigma, 3);
    disp('There are fewer GMM components than specified');
end

[~, dip_ind_all]=maxk(sum(GMM.dipoles.^2,2),numberOfModels);

list=zeros(size(points,1), numberOfModels);

for i=1:numberOfModels
    j=dip_ind_all(i);
    alpha = str2num(GMM.parameters.Values{6})/100;
    r = sqrt(chi2inv(alpha,3));
    [principal_axes,semi_axes]=eig(inv(GMM.model.Sigma(1:3,1:3,j))); %principal_axes(:,1) are the directions of the elipsoid, semi_axes their lengths
    semi_axes = transpose(r./sqrt(diag(semi_axes)));
    %ellipsoid(GMM.model.mu(j,1),GMM.model.mu(j,2),GMM.model.mu(j,3),semi_axes(1),semi_axes(2),semi_axes(3),100);

    %move cloud to origin
    pAll=points-[GMM.model.mu(j,1),GMM.model.mu(j,2),GMM.model.mu(j,3)];
    %rotate all points into the elipsoids direction by its inverse principal
    %axes
    pAll=principal_axes\pAll';
    pAll=pAll';

    pAll=pAll(:,1).^2/semi_axes(1)^2+pAll(:,2).^2/semi_axes(2)^2+pAll(:,3).^2/semi_axes(3)^2;

    list(:,i)=pAll<=1;

end

end
