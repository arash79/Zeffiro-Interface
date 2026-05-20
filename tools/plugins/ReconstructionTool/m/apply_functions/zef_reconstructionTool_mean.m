function [newRec] = zef_reconstructionTool_mean(reconstruction)
% --- Zeffiro documentation header ---
% zef_reconstructionTool_mean — Zef reconstruction Tool mean.
%
% Purpose:
%   Zef reconstruction Tool mean.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   reconstruction
%
% Outputs:
%   newRec
%
% Calls (project):
%   zef_reconstructionTool_mean
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[newRec] = zef_reconstructionTool_mean(reconstruction)` with project root and `src` on the path.
% --- End Zeffiro documentation header


newRec=reconstruction{:,1};

for frame=2:size(reconstruction,2)
    nextRec=reconstruction{:,frame};
    newRec=newRec+nextRec;
end
newRec=newRec/size(reconstruction,2);
newRec={newRec};

end
