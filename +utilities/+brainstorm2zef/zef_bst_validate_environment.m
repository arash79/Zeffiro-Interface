function [is_valid, error_msg] = zef_bst_validate_environment()
%ZEF_BST_VALIDATE_ENVIRONMENT Validates that Brainstorm is available and properly configured.
%
% This function checks if Brainstorm is installed, accessible, and properly
% initialized before attempting to use Brainstorm functions.
%
% Outputs:
%   is_valid  - Logical indicating if Brainstorm environment is valid (true/false)
%   error_msg - String containing error message if validation fails (empty if valid)
%
% Example:
%   [is_valid, error_msg] = utilities.brainstorm2zef.zef_bst_validate_environment();
%   if ~is_valid
%       error('Brainstorm validation failed: %s', error_msg);
%   end
%
% See also: ZEF_BST_VALIDATE_SETTINGS

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
