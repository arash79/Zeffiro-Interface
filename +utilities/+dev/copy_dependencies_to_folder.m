function messages = copy_dependencies_to_folder ( file, target_folder, kwargs )
% --- Zeffiro documentation header ---
% utilities.dev.copy_dependencies_to_folder — Copy dependencies to folder.
%
% Purpose:
%   Copy dependencies to folder.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   file
%   target_folder
%   kwargs
%
% Outputs:
%   messages
%
% Calls (project):
%   utilities.dev.copy_dependencies_to_folder
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[messages] = utilities.dev.copy_dependencies_to_folder(file, target_folder, kwargs)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
