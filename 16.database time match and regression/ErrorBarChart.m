figure
bar([1:5],chartdata50(1,:));
hold on
bar([6:10],chartdata50(2,:));
hold on
errorbar([1:5],chartdata50(1,:),chartdata50(1,:)-chartdata25(1,:),chartdata75(1,:)-chartdata50(1,:),'Marker','none','LineStyle','none');
