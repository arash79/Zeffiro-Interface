% --- Zeffiro documentation header ---
% function [reconstruction,reconstruction_information] = zef_reconstructionTool_import — Function [reconstruction,reconstruction information] = zef reconstruction Tool import.
%
% Purpose:
%   Function [reconstruction,reconstruction information] = zef reconstruction Tool import.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Calls (project):
%   zef_reconstructionTool_import
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `function [reconstruction,reconstruction_information] = zef_reconstructionTool_import` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

function [reconstruction,reconstruction_information] = zef_reconstructionTool_import


[importName, importPath]=uigetfile('./', 'select reconstruction file', '*.mat');

reconstruction_information=[];
reconstruction=[];

load(strcat(importPath, importName));

if isempty(reconstruction_information)
    reconstruction_information.tag=importName;
end

end
