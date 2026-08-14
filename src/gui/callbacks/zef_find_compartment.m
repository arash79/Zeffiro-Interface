function compartment_tag = zef_find_compartment(property_name,property_value)
%ZEF_FIND_COMPARTMENT  First compartment tag whose <tag>_<property> matches.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Caller: zef_bst_2_zef_atlas (match atlas name).
%   Function; evalin('base','zef.compartment_tags') and zef.<tag>_*.
%
%   compartment_tag = zef_find_compartment(property_name, property_value)
%
%   Inputs
%     property_name   - field suffix, e.g. 'name'.
%     property_value  - char (quoted for eval) or numeric (string()).
%
%   Output
%     compartment_tag  - matching tag, or '' if none.
%
%   Walks tags from the end (table row 1) toward the start so the
%   outermost / last-listed tissue wins when names collide.
%
%   See also zef_compartment_table_selection.

compartment_tags = evalin('base','zef.compartment_tags');

compartment_tag = '';
compartment_found = 0;
compartment_counter = 0;

if ischar(property_value)
    property_value = ['''' property_value ''''];
else
    property_value = char(string(property_value));
end

while not(compartment_found) && compartment_counter < length(compartment_tags)

    % tags{end} is table row 1 (reversed compartment_tags).
    if evalin('base',['isequal(zef.' compartment_tags{end-compartment_counter} '_' property_name ',' property_value ')'])
        compartment_tag = compartment_tags{end-compartment_counter};
        compartment_found = 1;
    end

    compartment_counter = compartment_counter + 1;

end

end
