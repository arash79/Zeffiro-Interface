%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_import_parcellation_colortable(zef,varargin)

if nargin==0

    zef = evalin('base','zef');

end

if isempty(zef)

    zef = evalin('base','zef');

end

fileFolder = zef.file_path ;

filename = '';

compartment_tag = '';

parcellation_merge = zef.parcellation_merge;

if not(isempty(varargin))

    filename = fullfile(varargin{1});

    if length(varargin) > 1

        compartment_tag = varargin{2};

    end

    if length(varargin) > 2

        parcellation_merge = varargin{3};

    end

end

if strlength(filename) == 0

    save_file_path = fullfile(zef.save_file_path);

    if or(not(isempty(save_file_path)),not(save_file_path==0))

        [file file_path, file_type] = uigetfile({'*.mat'},'Import parcellation colortable',save_file_path);

    else

        [file file_path, file_type] = uigetfile({'*.mat'},'Import parcellation colortable');

    end

    filename = fullfile(file_path, file);

end

filePath = zef_resolve_import_file(fileFolder, filename) ;

if not ( strlength ( filename ) == 0 )

    color_table_file_contents = load(filePath);

    vertices = color_table_file_contents.vertices;

    labels = color_table_file_contents.label;

    colortable = color_table_file_contents.colortable;

    parcellation_aux = { labels, vertices, struct2cell(colortable) };

    if not(parcellation_merge)

        zef.parcellation_interp_ind = cell(0);

        zef.parcellation_colortable = cell(0);

        parcellation_segment = 1;

    else

        zef.parcellation_colortable = zef.parcellation_colortable;

        parcellation_segment = zef.parcellation_segment;

    end

    zef.parcellation_colortable{length(zef.parcellation_colortable)+1} = { ...
        parcellation_segment, ...
        parcellation_aux{3}{3}, ...
        parcellation_aux{3}{4}, ...
        parcellation_aux{1} ...
        };

    if not(isempty(compartment_tag))

        zef.parcellation_colortable{length(zef.parcellation_colortable)}{5} = cell(0);

        for p_ind = 1 : size(parcellation_aux{3}{4},1)

            zef.parcellation_colortable{length(zef.parcellation_colortable)}{5}{p_ind,1} = compartment_tag;

            zef.parcellation_colortable{length(zef.parcellation_colortable)}{5}{p_ind,2} = 1;

        end

        zef.parcellation_colortable{length(zef.parcellation_colortable)}{6} = ones(size(parcellation_aux{3}{4},1),1);

    end


    zef.parcellation_selected = [];

    if eval('isfield(zef,''h_parcellation_list'')')

        if isvalid(zef.h_parcellation_list)

            h_parcellation_list = zef.h_parcellation_list;

            set(h_parcellation_list,'value',[]);

            zef = zef_update_parcellation(zef);

        end

    end

end

if nargout == 0

    assignin('base','zef',zef);

end

end % function

function filePath = zef_resolve_import_file(fileFolder, filename)

filePath = filename;

if isempty(filePath)
    return;
end

if isstring(filePath)
    filePath = char(filePath);
end

if isfile(filePath) || zef_is_absolute_path(filePath)
    return;
end

candidate = fullfile(fileFolder, filePath);

if isfile(candidate)
    filePath = candidate;
    return;
end

folder_path = char(fileFolder);
while not(isempty(folder_path)) && not(isempty(regexp(folder_path(end), '[\\/]', 'once')))
    folder_path(end) = [];
end

[parent_folder, folder_basename] = fileparts(folder_path);
filename_parts = regexp(filePath, '[\\/]', 'split');

if numel(filename_parts) > 1 && strcmp(filename_parts{1}, folder_basename)
    parent_candidate = fullfile(parent_folder, filePath);
    if isfile(parent_candidate)
        filePath = parent_candidate;
        return;
    end
end

filePath = candidate;

end % function

function is_absolute = zef_is_absolute_path(filePath)

is_absolute = not(isempty(regexp(filePath, '^(\/|\\|[A-Za-z]:[\\/])', 'once')));

end % function
