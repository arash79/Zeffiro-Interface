%ZEF_RECONSTRUCTIONTOOL_REFRESH  Fill the live-reconstruction row from zef.reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. RefreshButton and start-up. currentInfo columns: tag, type,
%   modality, n_frames, n_sources, lead_field_id. Cell reconstructions
%   use size(...,1) as n_frames and size({1},1) as n_sources; a non-cell
%   uses size(...,2) and size(...,1). Missing tag/type/modality become
%   'tag' / '' / ''; missing lead_field_id becomes 'no ID'. Writes
%   app.current.Data. Does not touch the bank table.
%
%   See also zef_reconstructionTool_addCurrent2bank, zef_reconstructionTool_start.

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
