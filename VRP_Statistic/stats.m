function stats
stats = getStats; %get data

perms = [1 2;1 3;1 4;2 3;2 4;3 4];%all permutations
params = struct('name',{'e','alpha','beta','tau0'}); %description of parameters
tasks = cell(1,length(stats));
for i = 1:length(tasks)
    tasks(1,i) = cellstr(sprintf('Task #%d',i)); 
end

colors = hsv(length(stats));
markerSize = length(tasks)*25; %marker
for permN = 1:length(perms(:,1))
    c1 = perms(permN,1);
    c2 = perms(permN,2);
    figure
    for task = 1:length(stats)
        plot(stats(task).params(:,c1),stats(task).params(:,c2),'color',colors(task,:));
        
        %s = scatter(stats(task).params(:,c1),stats(task).params(:,c2),'filled');
        %set(s,'SizeData',markerSize); %marker
        %markerSize = markerSize - length(tasks)*3; %marker
        
        xlabel(params(c1).name);
        ylabel(params(c2).name);
        hold on;
    end
    markerSize = length(tasks)*25; %marker
    
    legend(tasks);
    %hold off;%
end

end

