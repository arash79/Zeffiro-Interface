function zef_bst_edit_project(project_file_name)
%ZEF_BST_EDIT_PROJECT Opens a Zeffiro project file in the Zeffiro interface.
%
% This function provides a convenient way to open and edit an existing
% Zeffiro project file created from Brainstorm data.
%
% Inputs:
%   project_file_name - Path to the Zeffiro project file (.mat)
%
% See also: ZEFFIRO_INTERFACE

if exist(project_file_name,'file')
    zeffiro_interface('start_mode','display','open_project',project_file_name);
end

end