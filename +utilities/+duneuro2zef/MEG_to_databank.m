function zef = MEG_to_databank(zef)
%MEG_TO_DATABANK  Create Data Bank tree nodes MEG / measurements / leadfield.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same as EEG_to_databank with names 'MEG', 'MEG measurements',
%   'MEG leadfield'. Does not write L or measurements into the nodes.
%
%   zef = MEG_to_databank(zef)
%
%   See also EEG_to_databank.

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
