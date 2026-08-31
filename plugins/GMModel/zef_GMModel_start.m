function zef = zef_GMModel_start(zef)
%ZEF_GMMODEL_START  Entry point that opens the Gmmodel plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   INI callback (Inverse tools → Gaussian Mixture Model (SP)). Opens the
%   GMM window via zef_GMModel_open. Run button calls zef_cluster_reconstruction
%   on an existing zef.reconstruction (not L/measurements). Not an inverse
%   solver and not inverse.gmm.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_GMModel_open',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
