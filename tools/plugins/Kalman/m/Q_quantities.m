function [sigma, phi, B, C, D] = Q_quantities(P, m, G, y)
%Q_QUANTITIES  EM-style averages of P, m, G, y over time (sigma, phi, B, C, D).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [sigma, phi, B, C, D] = Q_quantities(P, m, G, y)
%
%   Not called from zef_KF. Helper for identifying Q from stored smoother
%   quantities. T = size(m,2)-1. C and D loops overwrite rather than
%   accumulate (as written). No zef fields.
%
%   See also RTS_smoother.
%

    T = size(m,2) - 1;

    sigma = zeros(size(P{1}));
    for k = 1:T
        sigma = sigma + P{k+1} + m{k+1}*m{k+1}';
    end
    sigma = sigma* 1/T;

    phi = zeros(size(P{1}));
    for k = 1:T
        phi = phi + P{k} + m{k}*m{k}';
    end
    phi = 1/T * phi;

    B = zeros(size(y{1},1), size(m{1}',2));
    for k = 1:T
        B = B + y{k+1} * m{k+1}';
    end
    B = 1/T * B;

    C = zeros(size(P{1},1),size( G{1}', 2));
    for k = 1:T
        C = P{k+1} * G{k}' + m{k+1} * m{k}';
    end
    C = 1/T * C;

    D = zeros(size(y,1));
    for k = 1:T
        D = y{k+1} * y{k+1}';
    end
    D = D * 1/T;

end
