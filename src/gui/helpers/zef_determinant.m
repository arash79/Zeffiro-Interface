function [d] = zef_determinant(a,b,c,varargin)
% --- Zeffiro documentation header ---
% zef_determinant — Zef determinant.
%
% Purpose:
%   Zef determinant.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   a
%   b
%   c
%   varargin
%
% Outputs:
%   d
%
% Calls (project):
%   zef_determinant
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[d] = zef_determinant(a, b, c, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


det_dir = 2;
if not(isempty(varargin))
    det_dir = varargin{1};
end

if det_dir == 1;
    d = a(1,:).*(b(2,:).*c(3,:) - c(2,:).*b(3,:)) - b(1,:).*(a(2,:).*c(3,:) - c(2,:).*a(3,:)) +  c(1,:).*(a(2,:).*b(3,:) - b(2,:).*a(3,:));
else
    d = a(:,1).*(b(:,2).*c(:,3) - c(:,2).*b(:,3)) - b(:,1).*(a(:,2).*c(:,3) - c(:,2).*a(:,3)) +  c(:,1).*(a(:,2).*b(:,3) - b(:,2).*a(:,3));
end

end
