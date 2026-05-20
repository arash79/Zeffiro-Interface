% MEG_to_databank.m
%
% Adds MEG-related data items to the Zeffiro Interface databank.
% This function creates a hierarchical structure in the databank for MEG
% measurements and lead field data.
%
% The function creates:
%   1. A custom 'MEG' node as the parent container
%   2. A 'MEG measurements' data item under the MEG node
%   3. A 'MEG leadfield' leadfield item under the MEG node
%
% Input:
%   zef - (Optional) Zeffiro Interface structure. If not provided, uses
%         the base workspace variable 'zef'.
%
% Output:
%   zef - Updated Zeffiro Interface structure with MEG databank entries
%         (also assigned to base workspace if nargout == 0)
%
% Usage:
%   % With return value
%   zef = utilities.duneuro2zef.MEG_to_databank(zef);
%
%   % Without return value (modifies base workspace)
%   utilities.duneuro2zef.MEG_to_databank();
%
% See also: EEG_to_databank.m, zef_dataBank_add_data_item

function zef = MEG_to_databank(zef)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.MEG_to_databank — MEG to databank.
%
% Purpose:
%   MEG to databank.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   utilities.duneuro2zef.MEG_to_databank
%   zef_dataBank_add_data_item
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = utilities.duneuro2zef.MEG_to_databank(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    if nargin < 1
        if evalin('base', 'exist(''zef'', ''var'')')
            zef = evalin('base', 'zef');
        else
            error('Zeffiro Interface structure ''zef'' not found in base workspace');
        end
    end
    
    % Create custom 'MEG' parent node in the databank
    zef = zef_dataBank_add_data_item(zef, 'custom', [], 'MEG');
    
    % Add MEG measurements data item under the MEG node
    zef = zef_dataBank_add_data_item(zef, 'data', 'MEG', 'MEG measurements');
    
    % Add MEG lead field data item under the MEG node
    zef = zef_dataBank_add_data_item(zef, 'leadfield', 'MEG', 'MEG leadfield');
    
    % Assign to base workspace if no output requested
    if nargout == 0
        assignin('base', 'zef', zef);
    end

end
