function zef_plot_GMModel(varargin)
% --- Zeffiro documentation header ---
% zef_plot_GMModel — Renders or updates a plot_gmmodel figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_gmmodel figure from current `zef` state.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.GMModel (read)
%
% Calls (project):
%   zef_plot_GMModel
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_plot_GMModel(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

[X_0,Y_0,Z_0] = sphere(50);
h_axes = evalin('caller','h_axes_image');

f_ind = evalin('caller','f_ind');
delete(findobj(h_axes,'Tag','additional: Gaussian mixture model'));
GMModel = evalin('base','zef.GMModel');
c_map = lines(size(GMModel.Param.mu,1));

dipole_strengths = sqrt(sum(GMModel.dipole_moments.^2,2));

%[~,i] = max(GMModel.ComponentProportion);

%(prod(sqrt(eigs(GMModel.Sigma(:,:,i)))))^(1/3)
for i = 1 : size(GMModel.Param.mu,1)
    if not(isnan(dipole_strengths(i)))
        Aux_arr = sqrtm(GMModel.Param.Sigma(1:3,1:3,i))*[X_0(:) Y_0(:) Z_0(:)]';
        X = reshape(Aux_arr(1,:),size(X_0));
        Y = reshape(Aux_arr(2,:),size(Y_0));
        Z = reshape(Aux_arr(3,:),size(Z_0));
        p = GMModel.cluster_centres(i,1:3);
        h_surf = surf(h_axes,X+p(1),Y+p(2),Z+p(3));
        set(h_surf,'edgecolor','none','facecolor',c_map(i,:));
        set(h_surf,'Tag','additional: Gaussian mixture model');
    end
end

h_legend = legend('Location','SouthWest','Orientation','Vertical');
h_legend.Tag = 'additional: Gaussian mixture model';

end
