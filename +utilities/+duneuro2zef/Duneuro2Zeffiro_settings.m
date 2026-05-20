% Duneuro2Zeffiro_settings.m
%
% Configures Zeffiro Interface settings for Duneuro-imported meshes.
% This function sets up source modeling parameters, processing options, and
% performs necessary mesh processing steps after importing Duneuro data.
%
% This function is called from the import pipeline (.zef file) to configure
% Zeffiro Interface after data import is complete.
%
% The function performs the following operations:
%   1. Configures source direction mode and frequency parameters
%   2. Sets source constraints for different compartments
%   3. Builds compartment table and processes meshes
%   4. Performs surface downsampling and source interpolation
%
% Source direction modes:
%   1 - Normal to surface (constrained)
%   2 - Tangential to surface
%   3 - Unconstrained (all directions)
%
% Compartment source settings:
%   2 - Constrained (normal to surface)
%   3 - Unconstrained (all directions)
%
% This function can be used in two ways:
%   1. As a script: Called automatically from Duneuro2Zeffiro_import.zef (line 19)
%   2. As a function: Called programmatically
%
% Input:
%   zef - (Optional) Zeffiro Interface structure. If not provided, uses
%         the base workspace variable 'zef'.
%
% Output:
%   zef - Updated Zeffiro Interface structure (also assigned to base workspace
%         if nargout == 0, for script mode compatibility)
%
% Usage:
%   % As script (automatic via .zef file):
%   % Called from Duneuro2Zeffiro_import.zef line 19
%
%   % As function (programmatic):
%   zef = utilities.duneuro2zef.Duneuro2Zeffiro_settings(zef);
%   % Or without input (uses base workspace):
%   utilities.duneuro2zef.Duneuro2Zeffiro_settings();
%
% See also: Duneuro2Zeffiro_convert.m, import_duneuro_project.m, Duneuro2Zeffiro_import.zef

function zef = Duneuro2Zeffiro_settings(zef)

    % Get zef from base workspace if not provided
    if nargin < 1 || isempty(zef)
        if evalin('base', 'exist(''zef'', ''var'')')
            zef = evalin('base', 'zef');
        else
            error('Zeffiro Interface structure ''zef'' not found in base workspace');
        end
    end
    
    % Set source direction mode to normal (constrained) sources
    zef.source_direction_mode = 1;
    
    % Configure sampling frequency for inverse processing (Hz)
    zef.inv_sampling_frequency = 2400;
    
    % Set frequency filter cutoffs (0 = no filtering)
    zef.inv_low_cut_frequency = 0;
    zef.inv_high_cut_frequency = 0;
    
    % Set source constraints for compartments
    % Check if compartment_tags exists and has at least 2 compartments
    if isfield(zef, 'compartment_tags') && length(zef.compartment_tags) >= 2
        % Set source constraints for first compartment (typically scalp)
        % 3 = unconstrained sources (all directions allowed)
        evalin('base', ['zef.' zef.compartment_tags{1} '_sources = 3;']);
        
        % Set source constraints for second compartment (typically brain)
        % 2 = constrained sources (normal to surface)
        evalin('base', ['zef.' zef.compartment_tags{2} '_sources = 2;']);
    else
        warning('Could not set compartment source constraints: insufficient compartments found');
    end
    
    % Build compartment table with updated source settings
    zef = zef_build_compartment_table(zef);
    
    % Open mesh tool GUI (optional, for visualization)
    zef_mesh_tool;
    
    % Process meshes: compute surface normals, adjacency, etc.
    zef = zef_process_meshes(zef);
    
    % Downsample surface meshes to reduce computational load
    zef = zef_downsample_surfaces(zef);
    
    % Reprocess meshes after downsampling
    zef = zef_process_meshes(zef);
    
    % Perform source interpolation: map source positions to mesh elements
    zef = zef_source_interpolation(zef);
    
    % Update base workspace with modified zef structure
    assignin('base', 'zef', zef);
    
    % In script mode (nargout == 0), don't return value
    if nargout == 0
        clear zef;
    end

end