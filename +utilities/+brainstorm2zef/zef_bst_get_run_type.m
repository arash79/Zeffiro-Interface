function [run_type] = zef_bst_get_run_type(h_parent)
%ZEF_BST_GET_RUN_TYPE Gets the run type selection from the plugin GUI.
%
% This function retrieves the current value of the run type popup menu
% from the Zeffiro-Brainstorm plugin interface.
%
% Inputs:
%   h_parent - Handle to parent figure (optional, uses gcbo if not provided)
%
% Outputs:
%   run_type - Integer value:
%              1 = Fresh start (load compartments from Brainstorm)
%              2 = Import compartments (use existing compartment data)
%              3 = Use existing project
%
% See also: ZEF_BST_PLUGIN_START

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

h_object = findobj(h_parent.Children,'Tag','run_type');
run_type = h_object.Value;

end