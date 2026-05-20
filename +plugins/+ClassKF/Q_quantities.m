function [sigma, phi, B, C, D] = Q_quantities(P, m, G, y)
%Q_QUANTITIES Compute auxiliary quantities for EM-based Q matrix estimation.
%
%   [SIGMA, PHI, B, C, D] = Q_QUANTITIES(P, M, G, Y) computes sample averages
%   used in expectation-maximization for estimating the process noise
%   covariance Q in a Kalman filter model. P, m are cell arrays of posterior
%   covariances and means; G is the Kalman gain sequence; y is measurements.
%
%   Inputs:
%     P - Cell array of posterior covariances P{k} at time k
%     M - Cell array of state means m{k}
%     G - Cell array of Kalman gains G{k}
%     Y - Cell array of measurements y{k}
%
%   Outputs:
%     SIGMA - Average of P{k+1} + m{k+1}*m{k+1}'
%     PHI   - Average of P{k} + m{k}*m{k}'
%     B     - Average of y{k+1}*m{k+1}'
%     C     - Average of P{k+1}*G{k}' + m{k+1}*m{k}'
%     D     - Average of y{k+1}*y{k+1}'
%
%   Note: D uses size(y,1) which may need to be size(y{1},1) for correctness.

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
