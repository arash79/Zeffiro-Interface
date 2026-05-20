function messages = copy_dependencies_to_folder ( file, target_folder, kwargs )
%COPY_DEPENDENCIES_TO_FOLDER Copy file dependencies into a target folder.
%
% MESSAGES = utilities.copy_dependencies_to_folder(FILE, TARGET_FOLDER, kwargs)
% discovers all non-built-in dependencies of FILE via
% matlab.codetools.requiredFilesAndProducts, then copies those files into
% TARGET_FOLDER. TARGET_FOLDER must already exist.
%
% Note: requiredFilesAndProducts only reports files on the MATLAB path. Add
% relevant directories with addpath(genpath("folder")) if dependencies lie
% outside the current path.
%
% Inputs:
%   file           - (1,1) string, mustBeFile
%                     Path to the script/function whose dependencies are copied.
%   target_folder  - (1,1) string, mustBeFolder
%                     Destination directory for dependency files.
%   kwargs.folder_whitelist - (:,1) string, mustBeFolder, default string([])
%                     If non-empty, only dependencies whose parent directory is
%                     in this list are copied (e.g. to exclude UI/waitbar code).
%                     If empty, all discovered dependencies are copied.
%
% Outputs:
%   messages - (:,1) string
%              Error messages from copyfile for any failed copies; empty if none.
%

    arguments

        file (1,1) string { mustBeFile }

        target_folder (1,1) string { mustBeFolder }

        kwargs.folder_whitelist (:,1) string { mustBeFolder } = string ( [] )

    end

    % Resolve whitelist entries to full paths for comparison with dependency paths.
    full_whitelist_paths = repmat ( "", numel ( kwargs.folder_whitelist ), 1 ) ;

    for ii = 1 : numel ( kwargs.folder_whitelist )

        dir_structs = dir ( kwargs.folder_whitelist (ii) ) ;

        folder_paths = dir_structs.folder ;

        unique_folder_paths = unique ( folder_paths ) ;

        full_whitelist_paths (ii) = string ( unique_folder_paths ) ;

    end % for

    % Discover all required files (excluding MATLAB built-ins).
    [ filepath_cells, ~ ] = matlab.codetools.requiredFilesAndProducts ( file ) ;

    if isrow ( filepath_cells )

        filepath_cells = transpose ( filepath_cells ) ;

    end

    file_paths = string ( filepath_cells ) ;

    n_of_files = numel ( file_paths ) ;

    message_count = 0 ;

    messages = repmat ("", n_of_files, 1 ) ;

    % Copy each dependency to target_folder (respecting whitelist when set).
    for fi = 1 : numel ( file_paths )

        fpath = file_paths ( fi ) ;

        status = 1 ;

        message = "" ;

        if isempty ( full_whitelist_paths )

            [ status, message, ~ ] = copyfile ( fpath, target_folder ) ;

        else
            [ parent, ~, ~ ] = fileparts ( fpath ) ;

            if ismember ( parent, full_whitelist_paths )

                [ status, message, ~ ] = copyfile ( fpath, target_folder ) ;

            end

        end % if

        if status ~= 1 && not ( isempty ( message ) )

            message_count = message_count + 1 ;

            messages ( fi ) = message ;

        end

    end % for

    % Return only slots that received an error message.
    difference = n_of_files - message_count ;
    if difference > 0
        messages = messages ( 1 : end - difference ) ;
    else
        messages = string ( [] ) ;
    end

end % function
