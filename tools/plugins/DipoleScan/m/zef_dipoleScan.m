function [z, reconstruction_information] = zef_dipoleScan(zef)
%ZEF_DIPOLESCAN  Dipole scan (single-dipole fit) inverse plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [z, reconstruction_information] = zef_dipoleScan(zef)
%
%   Called from Dipole Scan StartButton (not inverse.DipoleScanInverter).
%   Needs zef.L and zef.measurements. Frames: zef.number_of_frames,
%   zef_getFilteredData / zef_getTimeStep. Method/regularization from
%   zef.dipole_app.InversionmethodDropDown / regType / inv_leadfield_lambda
%   (SVD or pinv). SNR stored in reconstruction_information (zef.inv_snr).
%   Returns cell z (one vector per frame) and info. onlymax is false as
%   written (full GOF map, not a single peak).
%
%   See also zef_dipole_start, zef_dipole_window.
%

invMethod=eval( 'zef.dipole_app.InversionmethodDropDown.Value');
regType=eval( 'zef.dipole_app.regType.Value');
inv_leadfield_lambda=eval( 'zef.dipole_app.inv_leadfield_lambda.Value');

%super unelegant call for the information
reconstruction_information.tag =strcat('Dipole', invMethod);
reconstruction_information.type = 'Dipole';
reconstruction_information.invMethod=invMethod;
reconstruction_information.regType=regType;
reconstruction_information.inv_leadfield_lambda=inv_leadfield_lambda;
reconstruction_information.inv_time_1 = eval('zef.inv_time_1');
reconstruction_information.inv_time_2 = eval('zef.inv_time_2');
reconstruction_information.inv_time_3 = eval('zef.inv_time_3');
reconstruction_information.sampling_freq = eval('zef.inv_sampling_frequency');
reconstruction_information.low_pass = eval('zef.inv_high_cut_frequency');
reconstruction_information.high_pass = eval('zef.inv_low_cut_frequency');
reconstruction_information.source_direction_mode = eval('zef.source_direction_mode');
reconstruction_information.source_directions = eval('zef.source_directions');
reconstruction_information.inv_hyperprior = eval('zef.inv_hyperprior');
reconstruction_information.snr_val = eval('zef.inv_snr');
reconstruction_information.number_of_frames = eval('zef.number_of_frames');

h = zef_waitbar(0,1,'Dipole scanning');

number_of_frames = eval('zef.number_of_frames');
source_direction_mode = eval('zef.source_direction_mode');

[L,n_interp, procFile] = zef_processLeadfields(zef);

z = cell(number_of_frames,1);
f_data = zef_getFilteredData(zef);

tic;
for f_ind = 1 : number_of_frames

    time_val = toc;
    if f_ind > 1
        date_str = datestr(datevec(now+(number_of_frames/(f_ind-1) - 1)*time_val/86400)); %what does that do?
        zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);

    end

    f=zef_getTimeStep(f_data, f_ind, zef);

    z_vec = nan(size(L,2),1);

    %% inversion starts here

    directionWise=false;

    switch source_direction_mode

        case {1,2}

            normal=procFile.s_ind_4;
            notNormal=setdiff(1:length(procFile.s_ind_0), procFile.s_ind_4);
            % mom=cell(size(L,2)/3);
            %for i=1:size(L,2)/3
            % Cortical-normal sources: 1-column lead field; store GOF on all 3 slots.
            for j=1:length(normal)
                i=normal(j);

                %                      if isequal(L(:,i),L(:,i+n_interp), L(:,i+2*n_interp))
                lf=L(:,i);
                %                      else
                %                          lf=[L(:,i), L(:,i+n_interp), L(:,i+2*n_interp)];
                %                      end

                %

                %     if cfg.reduceDim < size(lf, 2)
                %         lf=lf*V(:, 1:cfg.reduceDim); %columns of V are the right singular vectors
                %         [U,S,V]=svd(lf, 'econ');
                %
                %     end

                switch invMethod

                    case 'SVD'
                        [U,S,V]=svd(lf, 'econ'); %this will create problems of L=Ln
                        mom=V*(S\(U'))*f;
                    case 'pinv'
                        mom=pinv(lf)*f;

                end

                %mom{i}=V*S\U'*f; %S\U is better than inv(S)*U
                %

                %resvar(i)=sum(f'*f)-sum(f'*(U*U')*f);

                % pot = lf*mom{i}';
                pot = lf*mom;

                %relativ residual variance
                z_vec(i) = 1 - sum((f-pot).^2) ./ sum(f.^2); %goodnes of fit
                z_vec(i+n_interp)=z_vec(i);
                z_vec(i+2*n_interp)=z_vec(i);

            end

            % Free-orientation sources: 3-column lf; optional SVD rank from
            % inv_leadfield_lambda; store GOF * unit moment on xyz.
            for j=1:length(notNormal)
                i=notNormal(j);

                %                      if isequal(L(:,i),L(:,i+n_interp), L(:,i+2*n_interp))
                %                       lf=L(:,i);
                %                      else
                lf=[L(:,i), L(:,i+n_interp), L(:,i+2*n_interp)];
                %                      end

                %

                if strcmp('SVD', regType)
                    % Reduce the 3-column lf to inv_leadfield_lambda right
                    % singular vectors (regType ItemsData 'SVD', not '1').
                    [~,~,V_reg]=svd(lf, 'econ');
                    lf=lf*V_reg(:, 1:str2double(inv_leadfield_lambda)); %columns of V are the right singular vectors

                end

                %mom{i}=V*S\U'*f; %S\U is better than inv(S)*U
                %mom=V*S\U'*f;

                switch invMethod

                    case 'SVD'
                        [U,S,V]=svd(lf, 'econ'); %this will create problems of L=Ln
                        mom=V*(S\(U'))*f;
                        %mom=V*inv(S)*U'*f;
                    case 'pinv'
                        mom=pinv(lf)*f;

                end

                %resvar(i)=sum(f'*f)-sum(f'*(U*U')*f);

                % pot = lf*mom{i}';
                pot = lf*mom;

                if strcmp('SVD', regType)
                    %mom has to be redirected into the old orientation
                    %system
                    momReg=[0 0 0];
                    for kreg=1:str2double(inv_leadfield_lambda)
                        momReg(1)=momReg(1)+mom(kreg)*V_reg(1, kreg);
                        momReg(2)=momReg(2)+mom(kreg)*V_reg(2, kreg);
                        momReg(3)=momReg(3)+mom(kreg)*V_reg(3, kreg);
                    end
                    mom=momReg;
                    %mom=mom*V_reg(:, 1:str2double(inv_leadfield_lambda))
                end

                %relativ residual variance
                mom=mom/norm(mom);
                gof=1 - sum((f-pot).^2) ./ sum(f.^2); %goodnes of fit
                z_vec(i) = gof*mom(1);
                z_vec(i+n_interp)=gof*mom(2);
                z_vec(i+2*n_interp)=gof*mom(3);
            end

    end
    %%%%%

    onlymax=false;
    [z_max, z_ind]=max(z_vec);
    reconstruction_information.maximum=z_max;
    % estimation_attr "max" is unused: onlymax is never set from the GUI.
    if onlymax
        z_vec=z_vec-z_vec;
        z_vec(z_ind)=z_max;
    end

    z{f_ind}=z_vec;

    %%

end

z = zef_postProcessInverse(z, procFile);
z = zef_normalizeInverseReconstruction(z);

close(h);
