function [converged] = check_convergence(DV_old, DV_new)
    converged = isequal(DV_old, DV_new);
end