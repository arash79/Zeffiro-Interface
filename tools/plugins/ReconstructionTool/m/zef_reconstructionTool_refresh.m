% --- Zeffiro documentation header ---
% zef.reconstructionTool — Zef.reconstruction Tool.
%
% Purpose:
%   Zef.reconstruction Tool.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.lead_field_id (read)
%   zef.reconstruction (read)
%   zef.reconstructionTool (read)
%   zef.reconstruction_information (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.reconstructionTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.reconstructionTool.currentInfo=cell(1,6);

if isfield(zef, 'reconstruction_information') && isfield(zef.reconstruction_information, 'tag')
    zef.reconstructionTool.currentInfo{1}=zef.reconstruction_information.tag;
else
    zef.reconstructionTool.currentInfo{1}='tag';
end

if isfield(zef, 'reconstruction_information') && isfield(zef.reconstruction_information, 'type')
    zef.reconstructionTool.currentInfo{2}=zef.reconstruction_information.type;
else
    zef.reconstructionTool.currentInfo{2}='';
end

if isfield(zef, 'reconstruction_information') && isfield(zef.reconstruction_information, 'modality')
    zef.reconstructionTool.currentInfo{3}=zef.reconstruction_information.modality;
else
    zef.reconstructionTool.currentInfo{3}='';
end

if iscell(zef.reconstruction)
    zef.reconstructionTool.currentInfo{4}=size(zef.reconstruction, 1);
else
    zef.reconstructionTool.currentInfo{4}=size(zef.reconstruction, 2);
end

if iscell(zef.reconstruction) && zef.reconstructionTool.currentInfo{4}>=1
    zef.reconstructionTool.currentInfo{5}=size(zef.reconstruction{1}, 1);
else %is either empty cell or single frame
    zef.reconstructionTool.currentInfo{5}=size(zef.reconstruction,1);
end

if isfield(zef, 'lead_field_id')
    zef.reconstructionTool.currentInfo{6}=zef.lead_field_id;
else
    zef.reconstructionTool.currentInfo{6}='no ID';
end

%end

zef.reconstructionTool.app.current.Data=zef.reconstructionTool.currentInfo;
