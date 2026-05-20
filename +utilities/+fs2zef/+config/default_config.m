function config = default_config()
%
% default_config - Default configuration parameters for fs2zef pipeline
%
% Returns a struct with default configuration values for all pipeline modes.
% These can be overridden by passing custom parameters to run.m
%
% Outputs:
%   config - Struct with default configuration fields
%

    config = struct();
    
    % Output format options
    config.output_format = 'both';  % 'ascii', 'stl', or 'both'
    
    % Parcellation schemes to process
    config.parcellation_schemes = {'36', '76'};  % Desikan-Killiany and Destrieux
    
    % Transform calculation
    config.compute_transforms = 'auto';  % 'auto', true, false
    config.reference_volume = 'orig.mgz';  % Reference volume for transforms
    
    % File validation
    config.validate_outputs = true;
    config.validate_inputs = true;
    
    % Cleanup
    config.cleanup_intermediate = false;
    config.cleanup_on_error = false;
    
    % Electrode and bounding box
    config.include_electrodes = true;
    config.include_box = true;
    config.electrode_file = '';  % Empty means use built-in
    
    % Import file generation
    config.generate_import_file = true;
    config.import_file_name = 'import_segmentation.zef';
    config.sort_order = 'alphabetical';  % 'alphabetical', 'anatomical', 'custom'
    
    % Processing options
    config.parallel_processing = false;  % Future: parallel extraction
    config.verbose = true;
    config.progress_reporting = true;
    
    % Error handling
    config.continue_on_error = true;  % Continue if some compartments fail
    config.retry_failed = true;  % Retry failed extractions
    config.max_retries = 2;
    
    % FreeSurfer-specific
    config.fs_override = true;  % Use default FS paths if env vars not set
    config.fsf_output_format = 'nii.gz';
    
    % recon-all options (for full pipeline mode)
    config.recon_all_flags = '-all';  % Additional flags for recon-all
    
end % function
