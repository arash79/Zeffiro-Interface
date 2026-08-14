function zef = EEG_to_databank(zef)
%EEG_TO_DATABANK  Create Data Bank tree nodes EEG / measurements / leadfield.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Does not copy matrices: zef_dataBank_add_data_item creates
%     custom parent 'EEG'
%     data child 'EEG measurements'
%     leadfield child 'EEG leadfield'
%   under the current databank. Optional zef argument; else base workspace.
%   nargout==0 → assignin('base','zef',zef). Requires a running session with
%   the Data Bank plugin on the path (zef_start_dataBank).
%
%   zef = EEG_to_databank(zef)
%
%   See also MEG_to_databank, zef_dataBank_add_data_item.

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
