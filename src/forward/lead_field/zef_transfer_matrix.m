function [T, Schur_complement, A] = zef_transfer_matrix(zef, ...
    A                                                    ...
    ,                                                        ...
    B                                                    ...
    ,                                                        ...
    C                                                    ...
    ,                                                        ...
    n_of_fem_nodes                                       ...
    ,                                                        ...
    n_of_electrodes                                      ...
    ,                                                        ...
    electrode_model                                      ...
    ,                                                        ...
    permutation                                          ...
    ,                                                        ...
    precond                                              ...
    ,                                                        ...
    impedance_vec                                        ...
    ,                                                        ...
    impedance_inf                                        ...
    ,                                                        ...
    tol_val                                              ...
    ,                                                        ...
    m_max                                                ...
    ,                                                        ...
    schur_expression                                     ...
    )
%ZEF_TRANSFER_MATRIX  PCG solve of A X = B for EEG and TES electrode loads.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   After zef_stiffness_matrix and zef_build_electrodes, EEG and TES still
%   need the nodal potential for each independent electrode load. This
%   function is that solve. Only zef_lead_field_eeg_fem and
%   zef_lead_field_tes_fem call it. MEG and EIT copy the same PCG loops
%   into their own FEM files and do not come through here.
%
%   GPU (zef.use_gpu and gpu_count > 0): Jacobi-preconditioned CG, multiply
%   by 1./diag(A). The precond argument is ignored on this path.
%
%   CPU: if precond is 'ssor', symmetric successive over-relaxation
%   factors; otherwise incomplete Cholesky ichol(A, struct('type','nofill')).
%   That ichol call does not read zef.preconditioner_tolerance /
%   lf_param.cholinc_tol. The dispatcher still copies those fields, but
%   they have no effect on this solver.
%
%   CPU also starts or resizes a parpool to zef.parallel_processes and
%   solves columns in blocks of parallel_processes * processes_per_core.
%
%   PEM with infinite impedance zeros electrode 1 (Dirichlet reference)
%   inside the current PCG block, not the whole first block of columns.
%   Waitbar title is "Stencil PCG iteration". If a column fails tol_val,
%   T is [] and the function returns (GPU prints a char vector; CPU warns).
%
%   Schur_complement(:,i) = schur_expression(x, i). EEG and TES pass
%   opposite signs; this function does not flip them:
%     EEG:  finite Z → B'*x - C(:,i);  inf Z → -C(:,i)
%     TES:  finite Z → C(:,i) - B'*x;  inf Z →  C(:,i)
%
%   [T, Schur_complement, A] = zef_transfer_matrix(zef, A, B, C, N, L, ...
%       electrode_model, permutation, precond, impedance_vec, ...
%       impedance_inf, tol_val, m_max, schur_expression)
%
%   Inputs
%     zef               - session (use_gpu, gpu_count, parallel_processes,
%                         processes_per_core).
%     A                 - N-by-N sparse stiffness (returned permuted).
%     B                 - N-by-L electrode loads from zef_build_electrodes.
%     C                 - L-by-L (or compatible) electrode block.
%     n_of_fem_nodes    - N = size(A,1).
%     n_of_electrodes   - L = size(B,2).
%     electrode_model   - 'PEM' or CEM string used by the FEM cores.
%     permutation       - 'symamd','symmmd','symrcm', or identity.
%     precond           - 'ssor' or anything else (treated as ichol). GPU
%                         ignores this.
%     impedance_vec     - per-electrode impedance; scales that column's tol.
%     impedance_inf     - 1 → infinite-impedance PEM branch.
%     tol_val, m_max    - CG relative residual and iteration cap.
%     schur_expression  - function handle (x, i) → L-vector.
%
%   Outputs
%     T                  - N-by-L potentials (unpermuted nodal order).
%     Schur_complement   - L-by-L (filled column-wise).
%     A                  - permuted A used internally.
%
%   See also zef_stiffness_matrix, zef_build_electrodes, zef_lead_field_eeg_fem.

if isequal(permutation,'symamd')
    perm_vec = symamd(A)';
elseif isequal(permutation,'symmmd')
    perm_vec = symmmd(A)';
elseif isequal(permutation,'symrcm')
    perm_vec = symrcm(A)';
else
    perm_vec = [1:n_of_fem_nodes]';
end

iperm_vec = sortrows([ perm_vec [1:n_of_fem_nodes]' ]);
iperm_vec = iperm_vec(:,2);

A_aux = A(perm_vec,perm_vec);
A = A_aux;

% Create waitbar and its cleanup object.

wbtitle = 'Stencil PCG iteration';
wb = zef_waitbar(0,1, wbtitle);

cleanupfn = @zef_close_waitbar;
cleanupobj = onCleanup(@() cleanupfn(wb));

% Initialize transfer matrix T and Schur_complement

T = zeros(size(B,1), n_of_electrodes);
Schur_complement = zeros(n_of_electrodes);

% GPU START

if eval( 'zef.use_gpu') == 1 && eval( 'zef.gpu_count') > 0

    precond_vec = gpuArray(1./full(diag(A)));
    A = gpuArray(A);

    tol_val_eff = tol_val;
    relres_vec = gpuArray(zeros(1, n_of_electrodes));

    tic;

    for i = 1 : n_of_electrodes

        b = full(B(:,i));
        b = zef_pem_zero_reference_loads(b, i, electrode_model, impedance_inf);

        tol_val = min(impedance_vec(i),1)*tol_val_eff;

        x = zeros(n_of_fem_nodes,1);
        norm_b = norm(b);
        r = b(perm_vec);
        p = gpuArray(r);
        m = 0;
        x = gpuArray(x);
        r = gpuArray(r);
        p = gpuArray(p);
        norm_b = gpuArray(norm_b);

        % CG until relative residual drops below tol_val or m_max is hit.

        while( (norm(r)/norm_b > tol_val) && (m < m_max) )
            a = A * p;
            a_dot_p = sum(a.*p);
            aux_val = sum(r.*p);
            lambda = aux_val ./ a_dot_p;
            x = x + lambda * p;
            r = r - lambda * a;
            inv_M_r = precond_vec .* r;
            aux_val = sum(inv_M_r .* a);
            gamma = aux_val ./ a_dot_p;
            p = inv_M_r - gamma * p;
            m = m+1;
        end

        relres_vec(i) = gather(norm(r)/norm_b);
        r = gather(x(iperm_vec));
        x = r;

        T(:,i) = x;
        % Sign and C vs B'*x live in the caller-supplied handle (EEG ≠ TES).
        Schur_complement(:,i) = schur_expression(x, i);

        if tol_val < relres_vec(i)
            'Error: PCG iteration did not converge.'
            T = [];
            return
        end

        time_val = toc;

        zef_waitbar(                                                                                   ...
            i,n_of_electrodes                                                                      ...
            ,                                                                                          ...
            wb                                                                                     ...
            ,                                                                                          ...
            [wbtitle '. Ready: ' datestr(datevec(now+(n_of_electrodes/i - 1)*time_val/86400)) '.'] ...
            );

    end

else % Use CPU instead of GPU

    % Define preconditioner

    if isequal(precond,'ssor');
        S1 = tril(A)*spdiags(1./sqrt(diag(A)),0,n_of_fem_nodes,n_of_fem_nodes);
        S2 = S1';
    else
        S2 = ichol(A,struct('type','nofill'));
        S1 = S2';
    end

    tol_val_eff = tol_val;

    % Define block size

    parallel_processes = eval( 'zef.parallel_processes');

    have_pct = ~isempty(ver('parallel')) && ...
           license('test','Distrib_Computing_Toolbox');

    if have_pct
        if isempty(gcp('nocreate'))
            parpool(parallel_processes);
        else
            h_pool = gcp;
            if ~isequal(h_pool.NumWorkers, parallel_processes)
                delete(h_pool)
                parpool(parallel_processes);
            end
        end
    end

    processes_per_core = eval( 'zef.processes_per_core');
    tic;
    block_size =  parallel_processes*processes_per_core;

    for i = 1 : block_size : n_of_electrodes

        block_ind = [i : min(n_of_electrodes,i+block_size-1)];

        %Define right hand side

        b = full(B(:,block_ind));
        tol_val = min(impedance_vec(block_ind),1)*tol_val_eff;
        b = zef_pem_zero_reference_loads(b, block_ind, electrode_model, impedance_inf);

        %Iterate

        x_block_cell = cell(0);
        relres_cell = cell(0);
        relres_vec = zeros(1,length(block_ind));
        tol_val = tol_val(:)';
        norm_b = sqrt(sum(b.^2));
        block_iter_end = block_ind(end)-block_ind(1)+1;
        [block_iter_ind] = [1 : processes_per_core : block_iter_end];

        parfor block_iter = 1 : length(block_iter_ind)

            block_iter_sub = [block_iter_ind(block_iter) : min(block_iter_end,block_iter_ind(block_iter)+processes_per_core-1)];
            x = zeros(n_of_fem_nodes, length(block_iter_sub));
            r = b(perm_vec, block_iter_sub);
            aux_vec = S1 \ r;
            p = S2 \ aux_vec;
            m = 0;

            while( not(isempty(find(sqrt(sum(r.^2))./norm_b(block_iter_sub) > tol_val(block_iter_sub)))) & (m < m_max) )
                a = A * p;
                a_dot_p = sum(a.*p);
                aux_val = sum(r.*p);
                lambda = aux_val ./ a_dot_p;
                x = x + lambda .* p;
                r = r - lambda .* a;
                aux_vec = S1\r;
                inv_M_r = S2\aux_vec;
                aux_val = sum(inv_M_r.*a);
                gamma = aux_val ./ a_dot_p;
                p = inv_M_r - gamma .* p;
                m=m+1;
            end

            x_block_cell{block_iter} = x(iperm_vec,:);
            relres_cell{block_iter} = sqrt(sum(r.^2))./norm_b(block_iter_sub);

        end

        for block_iter = 1 : length(block_iter_ind)
            block_iter_sub = [block_iter_ind(block_iter) : min(block_iter_end,block_iter_ind(block_iter)+processes_per_core-1)];
            T(:,block_ind(block_iter_sub)) = x_block_cell{block_iter};
            relres_vec(block_iter_sub) = relres_cell{block_iter};
        end

        % Construct stencil T column by column.
        % Sign and C vs B'*x live in the caller-supplied handle (EEG ≠ TES).
        Schur_complement(:,block_ind) = schur_expression(T(:,block_ind), block_ind);

        if not(isempty(find(tol_val < relres_vec)))
            warning('Error: PCG iteration did not converge. Returning empty transfer matrix...')
            T = [];
            return
        end

        time_val = toc;

        zef_waitbar(                                                                                                ...
            (i+length(block_ind)-1) , n_of_electrodes                                                           ...
            ,                                                                                                       ...
            wb                                                                                                  ...
            ,                                                                                                       ...
            [wbtitle '. Ready: ' datestr(datevec(now+(n_of_electrodes/(i+length(block_ind)-1) - 1)*time_val/86400)) '.'] ...
            );

    end
end

zef_waitbar(1,1,wb);

end
