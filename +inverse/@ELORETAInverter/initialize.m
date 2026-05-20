function self = initialize(self, L, f_data)
%
% initialization function
%
% Initialize frame-invariant parameters before first inversion frame.
%

arguments
    self (1,1) inverse.ELORETAInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}
end

self.computing_parameters = true;

noise_p2 = 10^(-self.signal_to_noise_ratio/10);

if isempty(self.noise_cov)
    if size(f_data,2) > 1
        self.noise_cov = cov(f_data');
    else
        self.noise_cov = noise_p2 * mean(f_data.^2) * eye(size(L,1), "like", L);
    end
end

if isempty(self.regularization_parameter)
    self.regularization_parameter = ...
        trace(L*L') / (size(L,1) * 10^(self.signal_to_noise_ratio/10));
end

self.computing_parameters = false;

end
