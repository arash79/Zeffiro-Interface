function [results, summary] = collect_inverse_results(submissions, opts)
%COLLECT_INVERSE_RESULTS Wait jobs and collect saved inverse results.

arguments
    submissions (1,:) struct
    opts.WaitForCompletion (1,1) logical = true
end

results = cell(1, numel(submissions));
summary = repmat(struct( ...
    "job_id", NaN, ...
    "state", "", ...
    "success", false, ...
    "result_path", "", ...
    "error", "" ...
), 1, numel(submissions));

for idx = 1:numel(submissions)
    job = submissions(idx).job;
    result_path = string(submissions(idx).result_path);

    if opts.WaitForCompletion
        wait(job);
    end

    summary(idx).job_id = job.ID;
    summary(idx).state = string(job.State);
    summary(idx).result_path = result_path;

    if isfile(result_path)
        loaded = load(result_path);
        if isfield(loaded, "result")
            results{idx} = loaded.result;
            summary(idx).success = isfield(loaded.result, "success") && loaded.result.success;
            if isfield(loaded.result, "error")
                summary(idx).error = string(loaded.result.error);
            end
        else
            summary(idx).error = "Result file is missing variable 'result'.";
        end
    else
        summary(idx).error = "Result file missing.";
    end
end

end
