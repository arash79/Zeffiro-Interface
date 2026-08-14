function zef = zef_GMModel_update(zef)
%ZEF_GMMODEL_UPDATE  GMM widgets → zef.GMModel clustering parameters.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_GMModel_update(zef)
%
%   Called from Run before zef_cluster_reconstruction. Copies
%   max_n_clusters, credibility, n_dynamic_levels, reg_param,
%   max_n_iter, tol_val, frame_number. Does not write reconstruction.
%
%   See also zef_cluster_reconstruction.

zef.GMModel.max_n_clusters = str2num(zef.GMModel.h_max_n_clusters.String);
zef.GMModel.credibility = str2num(zef.GMModel.h_credibility.String);
zef.GMModel.n_dynamic_levels = str2num(zef.GMModel.h_n_dynamic_levels.String);
zef.GMModel.reg_param = str2num(zef.GMModel.h_reg_param.String);
zef.GMModel.max_n_iter = str2num(zef.GMModel.h_max_n_iter.String);
zef.GMModel.tol_val = str2num(zef.GMModel.h_tol_val.String);
zef.GMModel.frame_number = str2num(zef.GMModel.h_frame_number.String);

end
