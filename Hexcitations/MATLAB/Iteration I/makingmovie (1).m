for kk =1:10:size(xs,1)
    plot(xs(kk,:),ys(kk,:),'linewidth',2,'color','b')
    hold on
    scatter(xs(kk,:),ys(kk,:),100,'filled','MarkerFaceColor','b','MarkerEdgeColor','b')
    scatter([0],[0],300,'filled','MarkerFaceColor','k','MarkerEdgeColor','k')
    ylim([-N-1,N+1])
    xlim([-N-1,N+1])
    hold off
    drawnow()

end
