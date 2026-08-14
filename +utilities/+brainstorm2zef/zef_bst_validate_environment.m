function [is_valid, error_msg] = zef_bst_validate_environment()
%ZEF_BST_VALIDATE_ENVIRONMENT  exist('bst_get') and a live ProtocolInfo.SUBJECTS.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [is_valid, error_msg] = zef_bst_validate_environment
%
%   Fails if bst_get is not on the path, or bst_get('ProtocolInfo') errors,
%   is empty, or has no SUBJECTS field. Does not start Brainstorm.
%
%   See also run, zef_bst_create_project.

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