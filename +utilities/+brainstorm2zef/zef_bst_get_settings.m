function zef_bst = zef_bst_get_settings(settings_file_name, zef_bst)
%ZEF_BST_GET_SETTINGS Loads and merges settings from file with provided structure.
%
% This function loads default settings, then applies settings from a
% specified settings file, and finally merges any provided settings
% (which take precedence). It also ensures parallel_processes doesn't
% exceed system capabilities and validates the final settings.
%
% Inputs:
%   settings_file_name - Name of settings file (without .m extension)
%   zef_bst            - Structure with settings to override defaults (optional)
%
% Outputs:
%   zef_bst - Merged settings structure with:
%             - Default values from zef_bst_init
%             - Values from specified settings file
%             - Overrides from input zef_bst (highest priority)
%
% Example:
%   zef_bst = utilities.brainstorm2zef.zef_bst_get_settings('zef_bst_default', struct());
%
% See also: ZEF_BST_INIT, ZEF_BST_VALIDATE_SETTINGS

if nargin < 2
    zef_bst = struct;
end

% Save provided settings for later merge
zef_bst_aux = zef_bst;

% Initialize default settings
% Note: zef_bst_init is a script that sets zef_bst in the current workspace
try
    utilities.brainstorm2zef.zef_bst_init;
    % After running the script, zef_bst should be set in this function's workspace
    % If it wasn't set (shouldn't happen), initialize it
    if ~exist('zef_bst', 'var') || isempty(zef_bst)
        zef_bst = struct();
    end
catch ME
    error('Failed to initialize default settings: %s', ME.message);
end

% Load settings from specified file if provided
% Note: Settings files are scripts that modify zef_bst in the current workspace
if ~isempty(settings_file_name) && ~isequal(settings_file_name, '')
    [~, settings_file_name_base] = fileparts(settings_file_name);
    % Get the folder containing this function to locate settings folder
    plugin_folder = fileparts(mfilename('fullpath'));
    settings_folder = fullfile(plugin_folder, 'settings');
    settings_file_path = fullfile(settings_folder, [settings_file_name_base '.m']);
    
    if exist(settings_file_path, 'file')
        try
            run(settings_file_path);
            % Verify zef_bst still exists after running settings file
            if ~exist('zef_bst', 'var') || isempty(zef_bst)
                warning('Settings file %s did not set zef_bst. Using defaults.', settings_file_path);
                utilities.brainstorm2zef.zef_bst_init;  % Re-initialize defaults
            end
        catch ME
            warning('Error loading settings file %s: %s. Using defaults.', ...
                settings_file_path, ME.message);
            % Re-initialize defaults if settings file failed
            if ~exist('zef_bst', 'var') || isempty(zef_bst)
                utilities.brainstorm2zef.zef_bst_init;
            end
        end
    else
        warning('Settings file not found: %s. Using default settings.', settings_file_path);
    end
end

% Merge provided settings (they override file and default settings)
% Only merge fields that were actually provided (non-empty in zef_bst_aux)
if ~isempty(zef_bst_aux) && ~isempty(fieldnames(zef_bst_aux))
    fieldnames_aux = fieldnames(zef_bst_aux);
    for i = 1 : length(fieldnames_aux)
        zef_bst.(fieldnames_aux{i}) = zef_bst_aux.(fieldnames_aux{i});
    end
end

% Ensure parallel_processes doesn't exceed system capabilities
if isfield(zef_bst, 'parallel_processes') && isnumeric(zef_bst.parallel_processes)
    max_threads = maxNumCompThreads;
    if zef_bst.parallel_processes > max_threads
        zef_bst.parallel_processes = max_threads;
        warning('parallel_processes reduced to %d (system maximum)', max_threads);
    end
end

% Validate settings
[is_valid, error_msg] = utilities.brainstorm2zef.zef_bst_validate_settings(zef_bst);
if ~is_valid
    warning('Settings validation failed: %s. Some operations may fail.', error_msg);
end 

end