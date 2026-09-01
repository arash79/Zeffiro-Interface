function [z,Var_loc,reconstruction_information] = zef_beamformer(zef)
%ZEF_BEAMFORMER  LCMV / UNG / UG / scalar beamformer scan.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [z, Var_loc, reconstruction_information] = zef_beamformer(zef)
%
%   Called from Beamformer StartButton (not inverse.BeamformerInverter).
%   Needs zef.L and zef.measurements. Frames: zef.number_of_frames.
%   SNR: zef.inv_snr → 10^(-inv_snr/20). Covariance from f_data and
%   zef.cov_type / inv_cov_lambda. Type zef.bf_type 1–4 (LCMV, UNG, UG,
%   UNGsc). The button chooses which of z / Var_loc is stored as
%   zef.reconstruction (estimation_attr 1 / 2 / else).
%
%   See also zef_beamformer_start, zef_beamformer_window.
%

h = zef_waitbar(0,1,['Beamformer.']);
[procFile.s_ind_1] = unique(eval('zef.source_interpolation_ind{1}'));
n_interp = length(procFile.s_ind_1);
snr_val = eval('zef.inv_snr');
std_lhood = 10^(-snr_val/20);
lambda_cov = eval('zef.inv_cov_lambda');
lambda_L = eval('zef.inv_leadfield_lambda');
sampling_freq = eval('zef.inv_sampling_frequency');
high_pass = eval('zef.inv_low_cut_frequency');
low_pass = eval('zef.inv_high_cut_frequency');
number_of_frames = eval('zef.number_of_frames');
time_step = eval('zef.inv_time_3');
source_direction_mode = eval('zef.source_direction_mode');
source_directions = eval('zef.source_directions');
method_type = eval('zef.bf_type');
cov_type = eval('zef.cov_type');
L_reg_type = eval('zef.L_reg_type');
normalize_leadfield_value = eval('zef.beamformer.normalize_leadfield.Value');
need_sqrtm = ismember(method_type, [1, 2, 3]);
need_Cdec = ismember(method_type, [2, 4]);

switch method_type
    case 1
        reconstruction_information.tag = 'Beamformer/LCMV';
    case 2
        reconstruction_information.tag = 'Beamformer/UNG';
    case 3
        reconstruction_information.tag = 'Beamformer/UG';
    case 4
        reconstruction_information.tag = 'Beamformer/UNGsc';
end
reconstruction_information.inv_time_1 = eval('zef.inv_time_1');
reconstruction_information.inv_time_2 = eval('zef.inv_time_2');
reconstruction_information.inv_time_3 = eval('zef.inv_time_3');
reconstruction_information.sampling_frequency = eval('zef.inv_sampling_frequency');
reconstruction_information.low_pass = eval('zef.inv_high_cut_frequency');
reconstruction_information.high_pass = eval('zef.inv_low_cut_frequency');
reconstruction_information.source_direction_mode = eval('zef.source_direction_mode');
reconstruction_information.source_directions = eval('zef.source_directions');
reconstruction_information.snr_val = eval('zef.inv_snr');
reconstruction_information.number_of_frames = eval('zef.number_of_frames');

[L,n_interp, procFile] = zef_processLeadfields(zef);

L_aux = L;
S_mat = std_lhood^2*eye(size(L,1));

L_ind = zef_blocked_source_index(n_interp, source_direction_mode);
nn = size(L_ind, 1);
update_waiting_bar = floor(0.1*(nn-2));
is_constrained = false(nn, 1);
if source_direction_mode == 2 && isfield(procFile, 's_ind_4') && ~isempty(procFile.s_ind_4)
    is_constrained = ismember(L_ind(:,1), procFile.s_ind_4);
end

if number_of_frames > 1
    z = cell(number_of_frames,1);
    Var_loc = cell(number_of_frames,1);
else
    number_of_frames = 1;
end

f_data = zef_getFilteredData(zef);

if cov_type == 1
    % Full-data C once: measurement-based ridge λ·trace(C)/n I.
    C = (f_data-mean(f_data,2))*(f_data-mean(f_data,2))'/size(f_data,2);
    C = C+lambda_cov*trace(C)*eye(size(C))/size(f_data,1);
elseif cov_type == 2
    % Full-data C once: basic ridge λ I.
    C = (f_data-mean(f_data,2))*(f_data-mean(f_data,2))'/size(f_data,2);
    C = C + lambda_cov*eye(size(C));
end

C_sqrt = [];
C_dec = [];
L_whitened = [];
if cov_type == 1 || cov_type == 2
    [C_sqrt, C_dec, L_whitened] = i_factor_cov(C, L, need_sqrtm, need_Cdec);
end

tic;
%------------------ TIME LOOP STARTS HERE ------------------------------
for f_ind = 1 : number_of_frames
    time_val = toc;
    if f_ind > 1
        date_str = datestr(datevec(now+(number_of_frames/(f_ind-1) - 1)*time_val/86400));
    end

    if ismember(source_direction_mode, [1,2])
        z_aux = zeros(size(L,2),1);
        Var_aux = zeros(size(L,2),1);
    end
    if source_direction_mode == 3
        z_aux = zeros(3*size(L,2),1);
        Var_aux = zeros(3*size(L,2),1);
    end
    z_vec = ones(size(L,2),1);
    Var_vec = ones(size(L,2),1);

    f=zef_getTimeStep(f_data, f_ind, zef);
    size_f = size(f,2);

    if cov_type == 3
        % Pointwise (this frame only), measurement-based ridge.
        if size_f > 1
            C = (f-mean(f,2))*(f-mean(f,2))'/size(f,2);
        else
            C = (f-mean(f,1))*(f-mean(f,1))';
        end
        C = C+lambda_cov*trace(C)*eye(size(C))/size(f,1);
    elseif cov_type == 4
        % Pointwise, basic ridge λ I.
        if size_f > 1
            C = (f-mean(f,2))*(f-mean(f,2))'/size(f,2);
        else
            C = (f-mean(f,1))*(f-mean(f,1))';
        end
        C = C + lambda_cov*eye(size(C));
    end

    if cov_type == 3 || cov_type == 4
        [C_sqrt, C_dec, L_whitened] = i_factor_cov(C, L, need_sqrtm, need_Cdec);
    end

    if f_ind == 1
        zef_waitbar(0,1,h,['Beamformer. Time step ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    end

    %---------------CALCULATIONS STARTS HERE----------------------------------
    %Data covariance matrix and its regularization

    if method_type == 1
        %__ LCMV Beamformer __

        f = C_sqrt \ f;
        L_aux2 = L_whitened;

        for n_iter = 1:nn
            %Normalized directions are calculated via scalar beamformer
            if source_direction_mode == 2
                if is_constrained(n_iter)
                    L_aux = L_aux2(:,L_ind(n_iter,1));
                else
                    %Leadfield normalizations
                    if strcmp(normalize_leadfield_value,'1')
                        %Leadfield normalization suggested by
                        %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                        %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                        %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                        %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L_aux2(:,L_ind(n_iter,:))/norm(L_aux);
                    elseif strcmp(normalize_leadfield_value,'2')
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                    elseif strcmp(normalize_leadfield_value,'3')
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                    else
                        L_aux = L_aux2(:,L_ind(n_iter,:));
                    end
                end
            else
                %Leadfield normalizations
                if strcmp(normalize_leadfield_value,'1')
                    %Leadfield normalization suggested by
                    %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                    %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                    %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                    %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L_aux2(:,L_ind(n_iter,:))/norm(L_aux);
                elseif strcmp(normalize_leadfield_value,'2')
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                elseif strcmp(normalize_leadfield_value,'3')
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                else
                    L_aux = L_aux2(:,L_ind(n_iter,:));
                end
            end

            %Leadfield regularization
            if L_reg_type==1
                invLTinvCL = inv(L_aux'*L_aux+lambda_L*eye(size(L_aux,2)));
            elseif L_reg_type==2
                invLTinvCL = pinv(L_aux'*L_aux);
            end

            % Whitened data: f ← C^{-1/2} f, L ← C^{-1/2} L. Per source,
            % z = (L'L + λI)^{-1} L' f (ridge) or pinv(L'L) L' f.
            % Constrained-field nodes (s_ind_4) use the single normal
            % column; others use the 3-column triplet after optional
            % lead-field column/Frobenius/row normalization.
            % Var_vec stores trace(z z') as a scalar location strength.
            z_vec(L_ind(n_iter,:)) = real(invLTinvCL*L_aux'*f);
            %location estimation:
            Var_vec(L_ind(n_iter,:)) = trace(z_vec(L_ind(n_iter,:))*z_vec(L_ind(n_iter,:))');

            if mod(n_iter-2,update_waiting_bar) == 0
                if number_of_frames == 1 && n_iter > 1
                    time_val = toc;
                    date_str = datestr(datevec(now+(nn/(n_iter-1) - 1)*time_val/86400));
                end
                if f_ind > 1;
                    zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
                elseif number_of_frames == 1
                    zef_waitbar(n_iter,nn,h,['Beamformer iteration ',num2str(n_iter),' of ',num2str(nn),'. Ready: ' date_str '.']);
                end;
            end
        end

    elseif method_type == 2
        %__ Sekihara's Borgiotti-Kaplan Beamformer __
        %Inversion method is based on article's "Reconstructing Spatio-Temporal Activities of
        %Neural Sources Using an MEG Vector Beamformer Technique1" description.
        %K. Sekihara et al., IEEE TRANSACTIONS ON BIOMEDICAL ENGINEERING, VOL. 48, NO. 7, JULY 2001

        L_aux2 = L_whitened;

        for n_iter = 1:nn
            %Normalized directions are calculated via scalar beamformer
            if source_direction_mode == 2
                %=== NORMAL DIRECTIONED COMPONENTS ===
                if is_constrained(n_iter)
                    L_aux = L(:,L_ind(n_iter,1));
                    %Leadfield regularization
                    if L_reg_type==1
                        lambdaI = lambda_L*eye(size(L_aux,2));
                    end
                    L_aux = L_aux2(:,L_ind(n_iter,1));
                    if L_reg_type==2
                        weights = C_dec \pinv(L_aux)';
                    else
                        weights = (C_dec \L(:,L_ind(n_iter,1)))/(L_aux'*L_aux+lambdaI);
                    end
                    %Leadfield normalization can not be used with scalar beamformer and therefore need to be carefully valuated in general
                    %when norma leadfiel direction is used.
                    %=== CARTESIAN DIRECTIONED COMPONENTS ===
                else
                    L_aux = L(:,L_ind(n_iter,1));
                    %Leadfield regularization
                    if L_reg_type==1
                        lambdaI = lambda_L*eye(size(L_aux,2));
                    end
                    %Leadfield normalization
                    if strcmp(normalize_leadfield_value,'1')
                        %Leadfield normalization suggested by
                        %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                        %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                        %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                        %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                        L_aux = L_aux2(:,L_ind(n_iter,:))/norm(L_aux);
                        if ~ismember(L_reg_type,[2])
                            weights = C_dec \L_aux;
                            weights = weights/(L_aux'*L_aux+lambdaI);
                        else
                            weights = C_dec \pinv(L_aux)';
                        end
                    elseif strcmp(normalize_leadfield_value,'2')
                        L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                        if ~ismember(L_reg_type,[2])
                            weights = C_dec \L_aux;
                            weights = weights/(L_aux'*L_aux+lambdaI);
                        else
                            weights = C_dec \pinv(L_aux)';
                        end
                    elseif strcmp(normalize_leadfield_value,'3')
                        L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                        if ~ismember(L_reg_type,[2])
                            weights = C_dec \L_aux;
                            weights = weights/(L_aux'*L_aux+lambdaI);
                        else
                            weights = C_dec \pinv(L_aux)';
                        end
                    else
                        L_aux = L_aux2(:,L_ind(n_iter,:));
                        if ~ismember(L_reg_type,[2])
                            weights = C_dec \L_aux;
                            weights = weights/(L_aux'*L_aux+lambdaI);
                        else
                            weights = C_dec \pinv(L_aux)';
                        end
                    end
                end
            else
                L_aux = L(:,L_ind(n_iter,1));
                %Leadfield regularization
                if L_reg_type==1
                    lambdaI = lambda_L*eye(size(L_aux,2));
                end
                %Leadfield normalization
                if strcmp(normalize_leadfield_value,'1')
                    %Leadfield normalization suggested by
                    %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                    %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                    %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                    %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                    L_aux = L_aux2(:,L_ind(n_iter,:))/norm(L_aux);
                    if ~ismember(L_reg_type,[2])
                        weights = C_dec \L_aux;
                        weights = weights/(L_aux'*L_aux+lambdaI);
                    else
                        weights = weights*pinv(L_aux'*L_aux);
                    end
                elseif strcmp(normalize_leadfield_value,'2')
                    L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                    if ~ismember(L_reg_type,[2])
                        weights = C_dec \L_aux;
                        weights = weights/(L_aux'*L_aux+lambdaI);
                    else
                        weights = weights*pinv(L_aux'*L_aux);
                    end
                elseif strcmp(normalize_leadfield_value,'3')
                    L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                    if ~ismember(L_reg_type,[2])
                        weights = C_dec \L_aux;
                        weights = weights/(L_aux'*L_aux+lambdaI);
                    else
                        weights = C_dec \pinv(L_aux)';
                    end
                else
                    L_aux = L_aux2(:,L_ind(n_iter,:));
                    if ~ismember(L_reg_type,[2])
                        weights = C_dec \L_aux;
                        weights = weights/(L_aux'*L_aux+lambdaI);
                    else
                        weights = C_dec \pinv(L_aux)';
                    end
                end
            end
            % Unit-noise-gain (Borgiotti–Kaplan): column-normalize the
            % LCMV-style weights so ‖w‖=1, then z = w' f. Constrained-field
            % nodes (s_ind_4) skip lead-field column normalization.
            weights = weights./sqrt(sum(weights.^2,1));

            %dipole moment estimation:
            z_vec(L_ind(n_iter,:)) = real(weights'*f);
            %location estimation:
            Var_vec(L_ind(n_iter,:)) = trace(z_vec(L_ind(n_iter,:))*z_vec(L_ind(n_iter,:))');

            if mod(n_iter-2,update_waiting_bar) == 0
                if number_of_frames == 1 && n_iter > 1
                    time_val = toc;
                    date_str = datestr(datevec(now+(nn/(n_iter-1) - 1)*time_val/86400));
                end
                if f_ind > 1;
                    zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
                elseif number_of_frames == 1
                    zef_waitbar(n_iter,nn,h,['UNG iteration ',num2str(n_iter),' of ',num2str(nn),'. Ready: ' date_str '.']);
                end;
            end
        end

    elseif method_type == 3
        %__ Unit-Gain constraint Beamformer __

        f = C_sqrt \ f;
        L_aux2 = L_whitened;

        for n_iter = 1:nn
            %Normalized directions are calculated via scalar beamformer
            if source_direction_mode == 2
                if is_constrained(n_iter)
                    L_aux = L_aux2(:,L_ind(n_iter,1));
                else
                    %Leadfield normalizations
                    if strcmp(normalize_leadfield_value,'1')
                        %Leadfield normalization suggested by
                        %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                        %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                        %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                        %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L_aux2(:,L_ind(n_iter,:))/norm(L_aux);
                    elseif strcmp(normalize_leadfield_value,'2')
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                    elseif strcmp(normalize_leadfield_value,'3')
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                    else
                        L_aux = L_aux2(:,L_ind(n_iter,:));
                    end
                end
            else
                %Leadfield normalizations
                if strcmp(normalize_leadfield_value,'1')
                    %Leadfield normalization suggested by
                    %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                    %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                    %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                    %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L_aux2(:,L_ind(n_iter,:))/norm(L_aux);
                elseif strcmp(normalize_leadfield_value,'2')
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                elseif strcmp(normalize_leadfield_value,'3')
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L_aux2(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                else
                    L_aux = L_aux2(:,L_ind(n_iter,:));
                end
            end

            % Unit-gain: Rayleigh–Ritz smallest eigenvector of L'L (after
            % C^{-1/2} whitening) as the orientation, then the same 1-column
            % LCMV solve as type 1, multiplied back by that orientation.
            [opt_orientation ,~] = eigs(L_aux'*L_aux,1,'smallestabs');
            opt_orientation = opt_orientation/norm(opt_orientation);
            L_aux = L_aux*opt_orientation;

            %Leadfield regularization
            if L_reg_type==1
                invLTinvCL = inv(L_aux'*L_aux+lambda_L*eye(size(L_aux,2)));
            elseif L_reg_type==2
                invLTinvCL = pinv(L_aux'*L_aux);
            end

            %dipole momentum estimate:

            z_vec(L_ind(n_iter,:)) = real(invLTinvCL*L_aux'*f)*opt_orientation;
            %location estimation:
            Var_vec(L_ind(n_iter,:)) = trace(z_vec(L_ind(n_iter,:))*z_vec(L_ind(n_iter,:))');

            if mod(n_iter-2,update_waiting_bar) == 0
                if number_of_frames == 1 && n_iter > 1
                    time_val = toc;
                    date_str = datestr(datevec(now+(nn/(n_iter-1) - 1)*time_val/86400));
                end
                if f_ind > 1;
                    zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
                elseif number_of_frames == 1
                    zef_waitbar(n_iter,nn,h,['Beamformer iteration ',num2str(n_iter),' of ',num2str(nn),'. Ready: ' date_str '.']);
                end;
            end
        end

    elseif method_type==4

        % Scalar unit-noise-gain: no C^{-1/2} prewhitening of f. L_aux is
        % C_dec \L, L_aux2 = L' C^{-1} L, orientation from the generalized
        % eigenproblem eigs(L'L, L_aux2), then z = (L'L)^{-1/2} L' f
        % times that orientation. Constrained-field nodes use one column.

        for n_iter = 1:nn
            %Normalized directions are calculated via scalar beamformer
            if source_direction_mode == 2
                if is_constrained(n_iter)
                    L_aux = L(:,L_ind(n_iter,1));
                else
                    %Leadfield normalizations
                    if strcmp(normalize_leadfield_value,'1')
                        %Leadfield normalization suggested by
                        %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                        %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                        %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                        %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L(:,L_ind(n_iter,:))/norm(L_aux);
                    elseif strcmp(normalize_leadfield_value,'2')
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                    elseif strcmp(normalize_leadfield_value,'3')
                        L_aux = L(:,L_ind(n_iter,:));
                        L_aux = L(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                    else
                        L_aux = L(:,L_ind(n_iter,:));
                    end
                end
            else
                %Leadfield normalizations
                if strcmp(normalize_leadfield_value,'1')
                    %Leadfield normalization suggested by
                    %- B.D. Van Veen et al. "Localization of brain electrical activity via linearly constrained minimum variance spatial filtering",
                    %IEEE Trans. Biomed. Eng., vol. 44, pp. 867–880, Sept. 1997.
                    %- J. Gross and A.A. Ioannides. "Linear transformations of data space in MEG",
                    %Phys. Med. Biol., vol. 44, pp. 2081–2097, 1999.
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L(:,L_ind(n_iter,:))/norm(L_aux);
                elseif strcmp(normalize_leadfield_value,'2')
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,1));
                elseif strcmp(normalize_leadfield_value,'3')
                    L_aux = L(:,L_ind(n_iter,:));
                    L_aux = L(:,L_ind(n_iter,:))./sqrt(sum(L_aux.^2,2));
                else
                    L_aux = L(:,L_ind(n_iter,:));
                end
            end

            L_aux_c = C_dec \ L_aux;
            L_aux2 = L_aux' * L_aux_c;
            L_aux = L_aux_c;

            % Generalized Rayleigh–Ritz: smallest eigenvector of L'L vs L'C^{-1}L.
            [opt_orientation ,~] = eigs(L_aux'*L_aux,L_aux2, 1,'smallestabs');
            opt_orientation = opt_orientation/norm(opt_orientation);
            L_aux = L_aux*opt_orientation;

            %Leadfield regularization
            if L_reg_type==1
                invSqrtLTinvC2L = sqrt(inv(L_aux'*L_aux+lambda_L*eye(size(L_aux,2))));
            elseif L_reg_type==2
                invSqrtLTinvC2L = sqrt(pinv(L_aux'*L_aux));
            end

            %dipole momentum estimate:

            z_vec(L_ind(n_iter,:)) = real(invSqrtLTinvC2L*L_aux'*f)*opt_orientation; %orientation for the zef data format
            %location estimation:
            Var_vec(L_ind(n_iter,:)) = trace(z_vec(L_ind(n_iter,:))*z_vec(L_ind(n_iter,:))');

            if mod(n_iter-2,update_waiting_bar) == 0
                if number_of_frames == 1 && n_iter > 1
                    time_val = toc;
                    date_str = datestr(datevec(now+(nn/(n_iter-1) - 1)*time_val/86400));
                end
                if f_ind > 1;
                    zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
                elseif number_of_frames == 1
                    zef_waitbar(n_iter,nn,h,['Beamformer iteration ',num2str(n_iter),' of ',num2str(nn),'. Ready: ' date_str '.']);
                end;
            end
        end

    end
    %------------------------------------------------------------------
    z{f_ind} = z_vec;
    Var_loc{f_ind} = Var_vec;
end;

z = zef_postProcessInverse(z, procFile);
z = zef_normalizeInverseReconstruction(z);

Var_loc = zef_postProcessInverse(Var_loc, procFile);
Var_loc = zef_normalizeInverseReconstruction(Var_loc);

zef_close_waitbar(h);
end

function [C_sqrt, C_dec, L_whitened] = i_factor_cov(C, L, need_sqrtm, need_Cdec)
%I_FACTOR_COV  Factor C once per unique covariance (sqrtm and/or LU).
C_sqrt = [];
C_dec = [];
L_whitened = [];
if need_sqrtm
    C_sqrt = sqrtm(C);
    L_whitened = C_sqrt \ L;
end
if need_Cdec
    C_dec = decomposition(C);
end
end
