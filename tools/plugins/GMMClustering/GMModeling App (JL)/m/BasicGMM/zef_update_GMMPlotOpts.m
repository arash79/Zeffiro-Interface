%ZEF_UPDATE_GMMPLOTOPTS  Default empty dip_num/ellip_num to the K parameter.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called from zef_GMMPlotOpt and PlotModel/PlotAmp buttons.
%   If dip_num or ellip_num Values are empty, copy parameters.Values{1}
%   (component count). Does not draw.
%
%   See also zef_GMMPlotOpt, zef_PlotGMModel.

zef_ind = find(strcmp(zef.GMM.parameters.Tags,'dip_num'));
if isempty(zef.GMM.parameters.Values{zef_ind})
    zef.GMM.parameters.Values{zef_ind} = zef.GMM.parameters.Values{1};
end

zef_ind = find(strcmp(zef.GMM.parameters.Tags,'ellip_num'));
if isempty(zef.GMM.parameters.Values{zef_ind})
    zef.GMM.parameters.Values{zef_ind} = zef.GMM.parameters.Values{1};
end

clear zef_ind
