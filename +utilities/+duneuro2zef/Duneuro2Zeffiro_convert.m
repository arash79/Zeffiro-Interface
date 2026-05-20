% Duneuro2Zeffiro_convert.m
%
% Converts Duneuro export files to Zeffiro Interface format.
% This function is called from the import pipeline (.zef file) to perform
% the conversion step before data import.
%
% This function can be used in two ways:
%   1. As a script: Called automatically from Duneuro2Zeffiro_import.zef (line 1)
%   2. As a function: Called programmatically with optional configuration
%
% Input:
%   config - (Optional) Configuration structure. If not provided, uses defaults.
%            See get_default_config.m for available options.
%
% Output:
%   results - (Optional) Conversion results structure. If nargout == 0, errors
%             are displayed as warnings.
%
% Usage:
%   % As script (automatic via .zef file):
%   % Called from Duneuro2Zeffiro_import.zef line 1
%
%   % As function (programmatic):
%   results = utilities.duneuro2zef.Duneuro2Zeffiro_convert();
%   results = utilities.duneuro2zef.Duneuro2Zeffiro_convert(config);
%
% See also: run.m, get_default_config.m, import_duneuro_project.m, Duneuro2Zeffiro_import.zef

function results = Duneuro2Zeffiro_convert(config)

    % Use default configuration if not provided
    if nargin < 1 || isempty(config)
        config = utilities.duneuro2zef.get_default_config();
    end
    
    % Check if conversion was already done by checking for key output files
    % This prevents double conversion when called from .zef file after import_duneuro_project
    % Note: This check uses relative paths, so it assumes the function is called
    % from the project root directory where data/ folder exists
    
    output_folder = fullfile(config.output_folder);
    key_outputs = {config.output.mesh, config.output.source_space};
    
    if config.process_eeg
        key_outputs{end+1} = config.output.leadfield_eeg;
    end
    if config.process_meg
        key_outputs{end+1} = config.output.leadfield_meg;
    end
    
    all_exist = true;
    for i = 1:length(key_outputs)
        file_path = fullfile(output_folder, key_outputs{i});
        if ~isfile(file_path)
            all_exist = false;
            break;
        end
    end
    
    % If all key output files exist, skip conversion (already done)
    if all_exist
        if config.verbose
            fprintf('Conversion already completed (output files exist). Skipping conversion step.\n');
        end
        
        % Just ensure databank is initialized if in ZI context
        try
            if evalin('base', 'exist(''zef'', ''var'')')
                zef = evalin('base', 'zef');
                if ~isfield(zef, 'dataBank') || isempty(zef.dataBank)
                    zef = zef_start_dataBank(zef);
                    assignin('base', 'zef', zef);
                end
            end
        catch
            % Not in ZI context, continue
        end
        
        % Return success without re-converting
        if nargout > 0
            results = struct();
            results.success = true;
            results.errors = {};
            results.warnings = {};
            results.processed_files = key_outputs;
            results.config = config;
        end
        return;
    end
    
    % Run conversion
    results = utilities.duneuro2zef.run(config);
    
    % If called as script (no output), display warnings for errors
    if nargout == 0
        if ~results.success
            warning('Duneuro2Zeffiro: Conversion completed with errors. Check results.errors for details.');
            if ~isempty(results.errors)
                for i = 1:length(results.errors)
                    warning('Duneuro2Zeffiro: %s', results.errors{i});
                end
            end
        end
        clear results;  % Don't leave results in workspace when called as script
    end

end
