function zef_plot_GMModel_max(varargin)
%ZEF_PLOT_GMMODEL_MAX  Queue renderer: ellipsoid at the strongest GMModel dipole.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same zef.GMModel fields as zef_plot_GMModel (SP tool), but only the
%   component with max |dipole_moments|. Optional varargin{1} is the
%   facecolor (default 0.7*[0 1 1]). Tag: 'additional: Gaussian mixture model'.
%
%   zef_plot_GMModel_max
%   zef_plot_GMModel_max(color)
%
%   See also zef_plot_GMModel.

if not(isempty(varargin))
    color_val = varargin{1};
else
    color_val = 0.7*[0 1 1];
end


[X_0,Y_0,Z_0] = sphere(50);
h_axes = evalin('caller','h_axes_image');
delete(findobj(h_axes,'Tag','additional: Gaussian mixture model'));
GMModel = evalin('base','zef.GMModel');

[~,i] = max(sqrt(sum(GMModel.dipole_moments.^2,2)));

Aux_arr = sqrtm(GMModel.Param.Sigma(1:3,1:3,i))*[X_0(:) Y_0(:) Z_0(:)]';
X = reshape(Aux_arr(1,:),size(X_0));
Y = reshape(Aux_arr(2,:),size(Y_0));
Z = reshape(Aux_arr(3,:),size(Z_0));
p = GMModel.cluster_centres(i,1:3);
h_surf = surf(h_axes,X+p(1),Y+p(2),Z+p(3));
set(h_surf,'edgecolor','none','facecolor',color_val);
set(h_surf,'Tag','additional: Gaussian mixture model');


end
