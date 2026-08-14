function h_output = zef_find_object_handles(zef, h_input, h_output, node_name)
%ZEF_FIND_OBJECT_HANDLES  Recursively collect zef fields that are valid handles.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Only caller is zef_gather_object_handles, which
%   itself has no first-party callers.
%
%   h_output = zef_find_object_handles(zef, h_input)
%   h_output = zef_find_object_handles(zef, h_input, h_output, node_name)
%
%   Inputs
%     zef        - session (unused except as the default eval root).
%     h_input    - handle array to match (ismember); on failure the field
%                  is copied with its properties.
%     h_output   - struct to fill. Default struct().
%     node_name  - eval string of the struct to walk. Default 'zef'.
%
%   Output
%     h_output  - struct of matching handle fields; nested structs recurse.
%
%   See also zef_gather_object_handles.

if nargin < 3
    h_output = struct;
end

if nargin < 4
    node_name = 'zef';
end

fields = fieldnames(eval(node_name));
for i = 1 : length(fields)
    aux_string = [node_name '.' fields{i}];
    aux_field = eval(aux_string);
    try
        isvalid(aux_field);
        handle_test = true;
    catch
        handle_test = false;
    end
    if and(isobject(aux_field),handle_test)
        try
            if ismember(aux_field,h_input)
                h_output.(fields{i}) = aux_field;
            end
        catch
            h_output.(fields{i}) = aux_field;
            properties_aux = properties(aux_field);
            for k = 1 : length(properties_aux)
                h_output.(fields{i}).(properties_aux{k}) = aux_field.(properties_aux{k});
            end
        end

    elseif isstruct(eval(aux_string))
        h_output = zef_find_object_handles(zef, h_input, h_output, aux_string);
    end

end
end
