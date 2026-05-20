function zef = zef_update_transform(zef)
% --- Zeffiro documentation header ---
% zef_update_transform — Syncs GUI control values into `zef` for transform.
%
% Purpose:
%   Syncs GUI control values into `zef` for transform.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.aux_field_1 (read, write)
%   zef.aux_field_2 (read, write)
%   zef.aux_field_3 (read, write)
%   zef.aux_field_4 (read, write)
%   zef.aux_field_5 (read, write)
%   zef.current_tag (read)
%   zef.h_transform_table (read)
%
% Calls (project):
%   zef_update_transform
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_update_transform(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef.aux_field_1 = zef.h_transform_table.Data;
zef.aux_field_2 = [];
zef.aux_field_3 = [];
zef.aux_field_4 = {'transform_name','scaling','x_correction','y_correction','z_correction','xy_rotation','yz_rotation','zx_rotation','affine_transform'};
zef.aux_field_5 = cell(0);

for zef_i = 1 : size(zef.aux_field_1,1)

    if not(isnan(zef.aux_field_1{zef_i,1}))
        zef.aux_field_2 = [zef.aux_field_2 zef.aux_field_1{zef_i,1}];
        zef.aux_field_3 = [zef.aux_field_3 zef_i];
    end

end

[~,zef.aux_field_2] = sort(zef.aux_field_2);
zef.aux_field_3 = zef.aux_field_3(zef.aux_field_2);

for zef_i = 1 : length(zef.aux_field_3)
    zef.aux_field_5{zef_i} = zef.aux_field_1{zef.aux_field_3(zef_i),2};
end

for zef_i = 1 : length(zef.aux_field_4)

    if zef_i == 1
        eval(['zef.' zef.current_tag '_' zef.aux_field_4{zef_i} ' = cell(0);']);
        for zef_j = 1 : length(zef.aux_field_5)
            eval(['zef.' zef.current_tag '_' zef.aux_field_4{zef_i} '{' num2str(zef_j) '} = ''' zef.aux_field_5{zef_j} ''';']);
        end

    elseif zef_i == 9
        if not(isfield(zef,[zef.current_tag '_' zef.aux_field_4{zef_i}]))
            eval(['zef.' zef.current_tag '_' zef.aux_field_4{zef_i} ' = repmat({eye(4)},1,length(zef.aux_field_3));']);
        else
            eval(['zef.' zef.current_tag '_' zef.aux_field_4{zef_i} ' = zef.' zef.current_tag '_' zef.aux_field_4{zef_i} '([' num2str(zef.aux_field_3) ']);']);
        end
    else
        ['zef.' zef.current_tag '_' zef.aux_field_4{zef_i} ' = zef.' zef.current_tag '_' zef.aux_field_4{zef_i} '([' num2str(zef.aux_field_3) ']);']

        eval(['zef.' zef.current_tag '_' zef.aux_field_4{zef_i} ' = zef.' zef.current_tag '_' zef.aux_field_4{zef_i} '([' num2str(zef.aux_field_3) ']);']);
    end
end

zef = rmfield(zef,{'aux_field_1','aux_field_2','aux_field_3','aux_field_4','aux_field_5'});
clear zef_i zef_j;

zef_init_transform;

if nargout == 0
    assignin('base','zef',zef);
end

end
