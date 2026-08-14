function zef_plot_GMModel(varargin)
%ZEF_PLOT_GMMODEL  Queue renderer: covariance ellipsoids for zef.GMModel.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Gaussian Mixture Model (SP) overlay: one surf per component using
%   Param.Sigma(1:3,1:3,:) around cluster_centres. Skips NaN
%   |dipole_moments|. Deletes Tag 'additional: Gaussian mixture model'
%   on caller h_axes_image first. Caller f_ind is read and unused.
%   varargin unused. Not the JL GMMClustering plot (zef_dpq_plot_GMM).
%
%   zef_plot_GMModel
%
%   See also zef_plot_GMModel_max, zef_dpq_plot_GMM.

[X_0,Y_0,Z_0] = sphere(50);
h_axes = evalin('caller','h_axes_image');

f_ind = evalin('caller','f_ind');
delete(findobj(h_axes,'Tag','additional: Gaussian mixture model')
);
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
