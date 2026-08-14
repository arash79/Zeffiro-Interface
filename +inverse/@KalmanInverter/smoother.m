function [reconstruction, self] = smoother(self, z_inverse, L)
%smoother  Rauch–Tung–Striebel backward pass over stored posterior covariances.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Run after the frame loop when use_smoothing is true so invert stored
%   posterior_covs{f}. State transition A is identity of length(z_inverse{1}).
%   Process noise Q is self.evolution_cov.
%
%   smoother_type "RTS": standard RTS, G = P / (P+Q) when A = I, then
%   m_s = m + G (m_s - A m) backward. Filter-type-specific
%   standardization is reapplied on the backward pass in the rest of this
%   file. "Sample RTS": estimates Q from consecutive filtered states.
%
%   Inputs
%     z_inverse - cell, one n_dof×1 filtered vector per frame (same order
%                 as invert).
%     L         - lead field; used when a standardized smoother rebuilds D.
%
%   Outputs
%     reconstruction - cell of smoothed frames, same length as z_inverse.
%     self           - posterior_covs still present; filter state otherwise
%                      as left by invert.

    arguments

        self (1,1) inverse.KalmanInverter

        z_inverse

        L (:,:)

    end

A = eye(length(z_inverse{1}));
Q = self.evolution_cov;

h = zef_waitbar(0,'Smoothing');
if strcmp(self.smoother_type,"RTS")
    % RTS: P_ = A P A' + Q, G = P A' / P_, m_s = m + G (m_s - A m) backward in time.
    reconstruction = cell(0);
    for f_ind = self.number_of_frames:-1:1
        zef_waitbar(1 - f_ind/self.number_of_frames,h, ['Smoothing ' int2str(self.number_of_frames -f_ind) ' of ' int2str(self.number_of_frames) '.']);
    
        P = self.posterior_covs{f_ind};
        m = z_inverse{f_ind};
        % if A is Identity
        if (isdiag(A) && all(diag(A) - 1) < eps)
            P_ = P + Q;
            m_ = m;
            G =  P / P_;
        else
            P_ = A * P * A' + Q;
            m_ = A * m;
            G =  (P * A') / P_;
        end
        if f_ind == number_of_frames
            m_s = m;
            P_s = P;
        else
            m_s = m + G * (m_s - m_);
            P_s = P + G * (P_s - P_) * G';
        end
        
        if strcmp(self.method_type,"Basic Kalman filter")
            reconstruction{f_ind} = m_s;
        elseif strcmp(self.method_type,"Standardized Kalman filter")
            P_sqrtm = sqrtm(P_);
            B = L * P_sqrtm;
            G = B' / (B * B' + self.noise_cov);
            w_t = 1 ./ sqrt(sum(G.' .* B, 1))';
            reconstruction{f_ind} = w_t .* (P_sqrtm\m_s);
        elseif strcmp(self.method_type,"Approximated Standardized Kalman filter")
            % Approximating the inverse of square root matrix
            N = 5; M = 1;
            Z = eye(length(m));
            Y = P;
            invY = Z;
            invZ = Z;
            for n = 1:N
                for k = 1:M
                    invY = 2*invY-invY*Y*invY;
                    invZ = 2*invZ-invZ*Z*invZ;
                end
                Y = 0.5*(Y+invZ);
                Z = 0.5*(Z+invY);
            end
            P_sqrtm_right = Z;
            B = H * P;
            K = B*P_sqrtm_right;
            G = K' / (B * H' + R);
            w_t = 1 ./ sqrt(sum(G.' .* K, 1))';
            reconstruction{f_ind} = w_t .* (P_sqrtm_right\m_s);
        end
    end
elseif strcmp(self.smoother_type,"Sample RTS")
    z_inverse = cell2mat(z_inverse);
    if (isdiag(A) && all(diag(A) - 1) < eps)
        Q = cov((z_inverse(:,2:number_of_frames)-z_inverse(:,1:number_of_frames-1))');
    else
        Q = cov((z_inverse(:,2:number_of_frames)-A* z_inverse(:,1:number_of_frames-1))');
    end
    reconstruction = cell(0);
    for f_ind = self.number_of_frames:-1:1
        zef_waitbar(1 - f_ind/self.number_of_frames,h, ['Smoothing ' int2str(self.number_of_frames -f_ind) ' of ' int2str(self.number_of_frames) '.']);
    
        P = self.posterior_covs{f_ind};
        m = z_inverse(:,f_ind);
        % if A is Identity
        if (isdiag(A) && all(diag(A) - 1) < eps)
            P_ = P + Q;
            m_ = m;
            G =  P / P_;
        else
            P_ = A * P * A' + Q;
            m_ = A * m;
            G =  (P * A') / P_;
        end
        if f_ind == number_of_frames
            m_s = m;
            P_s = P;
        else
            m_s = m + G * (m_s - m_);
            P_s = P + G * (P_s - P_) * G';
        end
        
        reconstruction{f_ind} = m_s;
    end
else
    reconstruction = z_inverse;
end
close(h);

end
