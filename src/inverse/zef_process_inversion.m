function [zef,MethodClassObj] = zef_process_inversion(zef,MethodClassObj)

    %
    % zef_process_inversion
    %
    % A function that processes a given inverter, calling its inverse method
    % for a number of frames and producing a set of reconstructions. The
    % inverse methods require the following inputs:
    %
    % - self
    % - waitbar_handle
    % - frame
    % - L
    % - procFile
    % - source_direction_mode
    % - source_positions
    %

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

    % The only inverter that defines a smoother today is KalmanInverter,
    % whose smoother.m requires (self, z_inverse, L). Guard on
    % use_smoothing so we don't enter the smoother branch (and its buggy
    % interior) when smoothing wasn't requested, and pass L so the
    % signature matches when it is.
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
