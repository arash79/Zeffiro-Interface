%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_import_parcellation_points(zef, varargin)

if nargin == 0
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
    filename = varargin{1};
    if length(varargin) > 1
        parcellation_merge = varargin{2};
    end
end

if isempty(filename)

    save_file_path = zef.save_file_path;

    if not(isempty(save_file_path)) & not(save_file_path==0)
        [file file_path file_type] = uigetfile({'*.asc';'*.dat'},'Import parcellation points',save_file_path);
    else
        [file file_path file_type] = uigetfile({'*.asc';'*.dat'},'Import parcellation points');
    end
    filename = [file_path file];
end


[~,~,file_type_aux] = fileparts(filename);

if isequal(file_type_aux,'.asc')
    file_type = 1;
elseif isequal(file_type_aux,'.dat')
    file_type = 2;
end

filePath = zef_resolve_import_file(fileFolder, filename) ;

if not(isempty(filename))
    if not(parcellation_merge)
        zef.parcellation_points = cell(0);
    else
        zef.parcellation_points = zef.parcellation_points;
    end

    if file_type == 1
        zef_i = fopen(filePath);
        zef_j = textscan(zef_i,'%s',1,'delimiter','\n', 'headerlines',1);
        zef_j = str2num(zef_j{1}{1});
        zef_j = zef_j(1);

        zef_i = fopen(filePath);
        zef_k = textscan(zef_i,'%s',zef_j,'delimiter','\n', 'headerlines',2);

        zef_k = cellfun(@(v) zef_import_asc(v,1,4),zef_k{1},'uniformoutput',false);
        [zef.parcellation_points{length(zef.parcellation_points)+1}] = cell2mat(zef_k);

        clear zef_i zef_j zef_k;

    end

    if file_type == 2
        [zef.parcellation_points{length(zef.parcellation_points)+1}] = load(filePath);
    end



    if isfield(zef,'h_zef_import_parcellation_points')
        if isvalid(zef.h_zef_import_parcellation_points)
            if  isempty(zef.parcellation_points)
                set(zef.h_zef_import_parcellation_points,'foregroundcolor',[1 0 0]);
            else
                set(zef.h_zef_import_parcellation_points,'foregroundcolor',[0 0 0]);
            end
        end
    end

end

if nargout == 0
    assignin('base','zef',zef);
end

end

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
