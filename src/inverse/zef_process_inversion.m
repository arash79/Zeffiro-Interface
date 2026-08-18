function [zef,MethodClassObj] = zef_process_inversion(zef,MethodClassObj)
%ZEF_PROCESS_INVERSION  Run a class-based inverter over all frames and store results on zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   GUI-oriented inversion driver: processes the lead field via
%   zef_processLeadfields, runs utilities.inverse.run_frame_loop with the
%   supplied inverter object, optionally applies a method-specific smoother,
%   normalizes when requested, and writes zef.reconstruction plus
%   zef.reconstruction_information.
%
%   [zef, MethodClassObj] = zef_process_inversion(zef, MethodClassObj)
%
%   Inputs
%     zef            - session struct with lead field, measurements, and source
%                      grid fields required by zef_processLeadfields.
%     MethodClassObj - inverter instance (must satisfy
%                      inverse.CommonInverseParameters.isAnInverter).
%
%   Outputs
%     zef            - updated with reconstruction, reconstruction_information,
%                      and scalar inverter properties copied from MethodClassObj.
%     MethodClassObj - same object, possibly updated by smoother/terminate hooks.
%
%   For source_direction_mode 1 or 2, reorders L columns to node-wise (x,y,z)
%   triplets before inversion. Uploads L to GPU when zef.use_gpu and
%   zef.gpu_count > 0. Shows a zef_waitbar for the duration of the run.
%
%   See also zef_processLeadfields, zef_postProcessInverseClassObj,
%            utilities.inverse.run_frame_loop, zef_inverse_run.

    arguments

        zef (1,1) struct

        MethodClassObj (1,1) { inverse.CommonInverseParameters.isAnInverter }

    end

    % Initialize the waitbar with a cleanup object that automatically closes
    % the waitbar, if there is an interruption with Ctrl + C or when this
    % function exits.

    zef.reconstruction_information = struct;
    zef.reconstruction_information.tag = erase(class(MethodClassObj),["inverse","Inverter","."]);

    waitbar_title = "Building reconstructions with " + zef.reconstruction_information.tag + ".";

    waitbar_handle = zef_waitbar(0, waitbar_title);

    cleanup_fn = @(h) close(h);

    cleanup_obj = onCleanup(@() cleanup_fn(waitbar_handle));

    % Get needed parameters from zef.

    source_direction_mode = zef.source_direction_mode;

    %no method use this?:
    %source_directions = eval('zef.source_directions');

    %these ok for now
    zef.reconstruction_information.source_direction_mode = zef.source_direction_mode;
    zef.reconstruction_information.source_directions = zef.source_directions;

    [L,n_interp, procFile] = zef_processLeadfields(zef);

    if source_direction_mode == 1  || source_direction_mode == 2
        %indices to order components node-wise:
        s_reorder_ind = reshape((1:n_interp)+(0:n_interp:(2*n_interp))',[],1);
        L = L(:,s_reorder_ind);
    end

    % Set up the source space of active brain compartments:

    source_positions = zef.source_positions(procFile.s_ind_0,:);

    if zef.use_gpu && zef.gpu_count > 0
        L = gpuArray(L);
    end

    % The inverse result, which will be post-processed.
    %
    % TODO: can we transpose this cell bc then you can transform it to matrix
    % with cell2mat without much extra effort. Many other softwares uses the
    % matrix format.

    [z_inverse, MethodClassObj] = utilities.inverse.run_frame_loop( ...
        zef, ...
        MethodClassObj, ...
        L, ...
        procFile, ...
        source_direction_mode, ...
        source_positions, ...
        waitbar_handle, ...
        waitbar_title ...
    );

    % Inverters that define smoother.m today: KalmanInverter (optional RTS)
    % and UKFNMMInverter (optional RTS, then required NMM/UKF). Guard on
    % use_smoothing so Kalman does not enter its smoother when unused.
    % UKFNMM forces use_smoothing true so this hook runs exactly once.
    % Pass L so the signature matches.
    should_smooth = ismethod(MethodClassObj, 'smoother') ...
        && isprop(MethodClassObj, 'use_smoothing') ...
        && MethodClassObj.use_smoothing;
    if should_smooth
        [z_inverse, MethodClassObj] = MethodClassObj.smoother(z_inverse, L);
    end

    if ismethod(MethodClassObj,'terminateComputation')
        MethodClassObj = MethodClassObj.terminateComputation;
    end

    if MethodClassObj.normalize_reconstruction
       z_vec = reshape(cell2mat(z_inverse).^2,3,procFile.n_interp,MethodClassObj.number_of_frames);
       z_vec = squeeze(sum(z_vec,1));
       normalization_factor = sqrt(max(z_vec,[],'all'));
       z_vec = cell2mat(z_inverse)/normalization_factor;
       z_inverse = mat2cell(z_vec,size(z_vec,1),ones(1,MethodClassObj.number_of_frames));
    end
    zef.reconstruction = zef_postProcessInverseClassObj(z_inverse, procFile);

    %method specific reconstruction information
    props = properties(MethodClassObj);

    for n = 1:length(props)
        if max(size(MethodClassObj.(props{n}))) < 2 && not(iscell(MethodClassObj.(props{n})))
            zef.reconstruction_information.(props{n}) = MethodClassObj.(props{n});
        end
    end

end % function
