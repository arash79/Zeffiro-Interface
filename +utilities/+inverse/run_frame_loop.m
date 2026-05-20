% --- Zeffiro documentation header ---
% utilities.inverse.function [z_inverse, MethodClassObj] = run_frame_loop( ... — Function [z inverse, Method Class Obj] = run frame loop( .
%
% Purpose:
%   Function [z inverse, Method Class Obj] = run frame loop( ....
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef
%   MethodClassObj
%   L
%   procFile
%   source_direction_mode
%   source_positions
%   waitbar_handle
%   waitbar_title
%
% Zef fields (observed):
%   zef.gpu_count (read)
%   zef.inv_data_mode (read)
%   zef.inverse_initialization_measurements (read)
%   zef.normalize_data (read)
%   zef.use_gpu (read)
%
% Calls (project):
%   utilities.inverse.run_frame_loop
%   zef_getFilteredDataClassObj
%   zef_getTimeStepClassObj
%   zef_waitbar
%
% Side effects:
%   - GPU
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.inverse.function [z_inverse, MethodClassObj] = run_frame_loop( ...(zef, MethodClassObj, L, procFile, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header
function [z_inverse, MethodClassObj] = run_frame_loop( ...
    zef, ...
    MethodClassObj, ...
    L, ...
    procFile, ...
    source_direction_mode, ...
    source_positions, ...
    waitbar_handle, ...
    waitbar_title ...
)

arguments
    zef (1,1) struct
    MethodClassObj (1,1) { inverse.CommonInverseParameters.isAnInverter }
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    procFile (1,1) struct
    source_direction_mode
    source_positions (:,:) {mustBeA(source_positions,["double","gpuArray"])}
    waitbar_handle
    waitbar_title (1,1) string
end

z_inverse = cell(1, MethodClassObj.number_of_frames);
f_data = zef_getFilteredDataClassObj(zef, MethodClassObj);
if isempty(f_data)
    error("utilities.inverse:run_frame_loop:EmptyData", ...
        "No measurement data were returned for inv_data_mode '%s'.", ...
        string(zef.inv_data_mode));
end
if MethodClassObj.number_of_frames > size(f_data, 2)
    error("utilities.inverse:run_frame_loop:FrameCountExceedsData", ...
        "number_of_frames=%d exceeds the available measurement frames (%d).", ...
        MethodClassObj.number_of_frames, size(f_data, 2));
end

if ismethod(MethodClassObj,'initialize')
    if isfield(zef, "inverse_initialization_measurements") ...
            && ~isempty(zef.inverse_initialization_measurements)
        f_data_framed = zef.inverse_initialization_measurements;
    else
        f_data_framed = cell2mat(arrayfun( ...
            @(x) zef_getTimeStepClassObj(f_data, x, zef, MethodClassObj), ...
            1:MethodClassObj.number_of_frames, ...
            'UniformOutput', false ...
        ));
    end
    MethodClassObj = MethodClassObj.initialize(L, f_data_framed);
end

if ismethod(MethodClassObj,'precompute')
    MethodClassObj = i_precompute(MethodClassObj, L, procFile);
end

tic;
for f_ind = 1:MethodClassObj.number_of_frames
    time_val = toc;
    f = zef_getTimeStepClassObj(f_data, f_ind, zef, MethodClassObj);

    if zef.use_gpu && zef.gpu_count > 0
        f = gpuArray(f);
    end

    if f_ind > 1
        date_str = " Ready: " + datestr(datevec(now+(MethodClassObj.number_of_frames/(f_ind-1) - 1)*time_val/86400));
    else
        date_str = "";
    end

    zef_waitbar( ...
        f_ind/MethodClassObj.number_of_frames, ...
        waitbar_handle, ...
        waitbar_title ...
            + " Time step " ...
            + int2str(f_ind) ...
            + " of " ...
            + int2str(MethodClassObj.number_of_frames) ...
            + "." ...
            + date_str ...
    );

    [z_vec, MethodClassObj] = MethodClassObj.invert( ...
        f, ...
        L, ...
        procFile, ...
        source_direction_mode, ...
        source_positions, ...
        "use_gpu", zef.use_gpu, ...
        "normalize_data", zef.normalize_data ...
    );

    z_inverse{f_ind} = z_vec;
end

end

function MethodClassObj = i_precompute(MethodClassObj, L, procFile)
%I_PRECOMPUTE Call precompute with procFile when the inverter supports it.
%
% eLORETA uses procFile to distinguish fixed-orientation sources under
% source_direction_mode 2. Older inverter precompute methods only accept L,
% so we fall back only on the specific "too many inputs" failure mode.

try
    MethodClassObj = MethodClassObj.precompute(L, procFile);
catch ME
    if i_is_too_many_inputs(ME)
        MethodClassObj = MethodClassObj.precompute(L);
    else
        rethrow(ME);
    end
end
end

function tf = i_is_too_many_inputs(ME)
msg = lower(string(ME.message));
id = lower(string(ME.identifier));
tf = contains(msg, "too many input") ...
    || contains(id, "toomanyinput") ...
    || contains(id, "maxrhs");
end
