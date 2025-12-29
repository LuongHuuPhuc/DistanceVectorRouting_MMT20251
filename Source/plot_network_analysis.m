function plot_network_analysis(cost_before, cost_after_list, cost_final, cost_history, failure_iter, failure_links)

    figure('Name', "Distance Vector Routing Analysis", 'NumberTitle', 'off');
    tiledlayout(2, 2, 'Padding','compact', 'TileSpacing', 'compact');

    %% ===== SUBPLOT 1: TOPLOLOGY TRUOC LINK FAILURE =====
    ax1 = nexttile;
    plot_topology(cost_before, ax1, 'Topology Before Link Failure');

    %% ===== SUBPLOT 2: TOPOLOGY SAU LINK FAILURE =====
    ax2 = nexttile;
    if isempty(cost_after_list)
        title(ax2, 'Topology After Link Failure (No failure yet)');
        axis(ax2, 'off');
    else
        % Lay topology sau Failure CUOI CUNG (tinh trang mang xau nhat)
        cost_after = cost_after_list{end};
        plot_topology(cost_after, ax2, 'Topology After Link Failure');

        % Ghi chu failure
        iter_fail = failure_iter(end);
        u = failure_links(end, 1);
        v = failure_links(end, 2);
        subtitle(ax2, sprintf('Last Failure @ iter %d: Link  %d ↔ %d', iter_fail, u, v));
    end

    %% ===== SUBPLOT 3: SHORTEST PATH =====
    ax3 = nexttile;
    plot_shortest_path(cost_final, 1, size(cost_final, 1), ax3);
    title(ax3, 'Shortest Path (1 → N)');

    %% ==== SUBPLOT 4: CONVERGENCE =====
    ax4 = nexttile;
    plot(ax4, cost_history, '-o', 'LineWidth', 2); 
    grid(ax4, 'on'); 
    xlabel(ax4, 'Iteration');
    ylabel(ax4, 'Total Network Cost');
    title(ax4, 'Distance Vector Convergence');

    % Danh sach cac iteration co link failure 
    if ~isempty(failure_iter)
        hold(ax4, 'on');
        ylims = ylim(ax4);
        for k = 1 : length(failure_iter)
            xline(ax4, failure_iter(k), '--r', 'LineWidth', 1);
        end
        ylim(ax4, ylims);
        hold(ax4, 'off');
    end

    drawnow;
end