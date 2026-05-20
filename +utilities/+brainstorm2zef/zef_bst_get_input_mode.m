function [input_mode] = zef_bst_get_input_mode(h_parent)
%ZEF_BST_GET_INPUT_MODE Gets the input mode selection from the plugin GUI.
%
% This function retrieves the current value of the input mode popup menu
% from the Zeffiro-Brainstorm plugin interface.
%
% Inputs:
%   h_parent - Handle to parent figure (optional, uses gcbo if not provided)
%
% Outputs:
%   input_mode - Integer value:
%                1 = Use input files
%                2 = Ignore input files
%
% See also: ZEF_BST_PLUGIN_START

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

h_object = findobj(h_parent.Children,'Tag','input_mode');
input_mode = h_object.Value;

end