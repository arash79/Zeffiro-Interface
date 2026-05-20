function [is_valid, error_msg] = zef_bst_validate_environment()
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_validate_environment — Zef bst validate environment.
%
% Purpose:
%   Zef bst validate environment.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Outputs:
%   is_valid
%   error_msg
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_validate_environment
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `utilities.brainstorm2zef.zef_bst_validate_environment` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

is_valid = true;
error_msg = '';

% Check if Brainstorm functions are available
if ~exist('bst_get', 'file')
    is_valid = false;
    error_msg = 'Brainstorm is not available. Please ensure Brainstorm is installed and added to MATLAB path.';
    return;
end

% Try to get protocol info to verify Brainstorm is initialized
try
    protocol_info = bst_get('ProtocolInfo');
    if isempty(protocol_info) || ~isfield(protocol_info, 'SUBJECTS')
        is_valid = false;
        error_msg = 'Brainstorm protocol is not initialized. Please open Brainstorm and select a protocol.';
        return;
    end
catch ME
    is_valid = false;
    error_msg = sprintf('Brainstorm initialization error: %s', ME.message);
    return;
end

end
