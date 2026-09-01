function [z_inverse] = EnKF(m, A, P, Q, L, R, timeSteps, number_of_frames, n_ensembles)
%ENKF  Ensemble Kalman filter (n_ensembles samples of the source state).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   z_inverse = EnKF(m, A, P, Q, L, R, timeSteps, number_of_frames, n_ensembles)
%
%   zef_KF filter_type 2. Ensemble count from zef.KF.number_of_ensembles.
%   Forecast with process noise Q, correlation localization (abs(T)<0.05
%   zeroed), then K = C L' / (L C L' + R). z = mean(ensemble). Writes cell
%   z_inverse; no RTS.
%
%   See also zef_KF, kalman_filter.
%

P_full = P;
Q_full = Q;
if issparse(P), P_full = full(P); end
if issparse(Q), Q_full = full(Q); end

x_ensemble = mvnrnd(zeros(size(m)), P_full, n_ensembles)';
z_inverse = cell(0);
h = zef_waitbar(0,1, 'EnKF Filtering');
for f_ind = 1:number_of_frames
    zef_waitbar(f_ind,number_of_frames,h,...
        ['EnKF Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    w = mvnrnd(zeros(size(m)), Q_full, n_ensembles)';
    % Forecasts

    x_f = A * x_ensemble + w;
    C = cov(x_f');
    T = corrcoef(x_f');
    T(abs(T) < 0.05) = 0;
    C = C .* T;
    v = mvnrnd(zeros(size(R,1),1), R, n_ensembles);
    K = C * L' / (L * C * L' + R);
    x_ensemble = x_f + K *(f + v' - L*x_f);
    z_inverse{f_ind} = mean(x_ensemble,2);
end
zef_close_waitbar(h);
end
