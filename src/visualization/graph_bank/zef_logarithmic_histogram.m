function zef_logarithmic_histogram(parameter_vec)
%ZEF_LOGARITHMIC_HISTOGRAM  Histogram of log10(parameter_vec) with log y-axis.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Mesh visualization → Plot graph. Draws on zef.h_axes1 (base).

axes(evalin('base','zef.h_axes1'));

h_axes = evalin('base','zef.h_axes1');
cla(h_axes,'reset');
h_axes.Tag = 'axes1';

h_hist = histogram(log10(parameter_vec),200);
h_hist.FaceColor = [0.5 0.5 0.5];

hist_y = (h_hist.Values);
hist_x = 0.5*(h_hist.BinEdges(1:end-1)+h_hist.BinEdges(2:end));

set(gca,'xlim',[min(hist_x) max(hist_x)]);
set(gca,'ylim',[min(hist_y) max(hist_y)]);
set(gca,'xgrid','on');
set(gca,'ygrid','on');
set(gca,'yscale','log');
end
