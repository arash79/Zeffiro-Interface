% EEG_to_databank.m
%
% Adds EEG-related data items to the Zeffiro Interface databank.
% This function creates a hierarchical structure in the databank for EEG
% measurements and lead field data.
%
% The function creates:
%   1. A custom 'EEG' node as the parent container
%   2. An 'EEG measurements' data item under the EEG node
%   3. An 'EEG leadfield' leadfield item under the EEG node
%
% Input:
%   zef - (Optional) Zeffiro Interface structure. If not provided, uses
%         the base workspace variable 'zef'.
%
% Output:
%   zef - Updated Zeffiro Interface structure with EEG databank entries
%         (also assigned to base workspace if nargout == 0)
%
% Usage:
%   % With return value
%   zef = utilities.duneuro2zef.EEG_to_databank(zef);
%
%   % Without return value (modifies base workspace)
%   utilities.duneuro2zef.EEG_to_databank();
%
% See also: MEG_to_databank.m, zef_dataBank_add_data_item

function zef = EEG_to_databank(zef)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.EEG_to_databank — EEG to databank.
%
% Purpose:
%   EEG to databank.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   utilities.duneuro2zef.EEG_to_databank
%   zef_dataBank_add_data_item
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = utilities.duneuro2zef.EEG_to_databank(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    if nargin < 1
        if evalin('base', 'exist(''zef'', ''var'')')
            zef = evalin('base', 'zef');
        else
            error('Zeffiro Interface structure ''zef'' not found in base workspace');
        end
    end
    
    % Create custom 'EEG' parent node in the databank
    zef = zef_dataBank_add_data_item(zef, 'custom', [], 'EEG');
    
    % Add EEG measurements data item under the EEG node
    zef = zef_dataBank_add_data_item(zef, 'data', 'EEG', 'EEG measurements');
    
    % Add EEG lead field data item under the EEG node
    zef = zef_dataBank_add_data_item(zef, 'leadfield', 'EEG', 'EEG leadfield');
    
    % Assign to base workspace if no output requested
    if nargout == 0
        assignin('base', 'zef', zef);
    end

end
