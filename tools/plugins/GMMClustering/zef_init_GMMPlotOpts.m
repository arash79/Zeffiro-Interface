%ZEF_INIT_GMMPLOTOPTS  Default GMM_comp_ord / dip_num / ellip_* if missing.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. dip_num/ellip_num from zef.GMModel.NumComponents when
%   present (SP GMModel tool), else empty. Used by the older plot-
%   options path, not the JL app's zef_update_GMMPlotOpts.
%
%   See also zef_update_GMMPlotOpts.

if ~isfield(zef,'GMM_comp_ord')
    zef.GMM_comp_ord = 1;
end
if ~isfield(zef,'GMM_dip_comp')
    zef.GMM_dip_comp = [];
end
if ~isfield(zef,'GMM_ellip_comp')
    zef.GMM_ellip_comp = [];
end
if ~isfield(zef,'GMM_dip_num')
    if isfield(zef,'GMModel')
        if iscell(zef.GMModel)
            zef.GMM_dip_num = zef.GMModel{find(~cellfun(@isempty,zef.GMModel),1)}.NumComponents;
        else
            zef.GMM_dip_num = zef.GMModel.NumComponents;
        end
    else
        zef.GMM_dip_num = [];
    end
end
if ~isfield(zef,'GMM_ellip_num')
    if isfield(zef,'GMModel')
        if iscell(zef.GMModel)
            zef.GMM_ellip_num = zef.GMModel{find(~cellfun(@isempty,zef.GMModel),1)}.NumComponents;
        else
            zef.GMM_ellip_num = zef.GMModel.NumComponents;
        end
    else
        zef.GMM_ellip_num = [];
    end
end
if ~isfield(zef,'GMM_ellip_coloring')
    zef.GMM_ellip_coloring = 1;
end
if ~isfield(zef,'GMM_colors')
    zef.GMM_colors = [];
end
