function correl_VRP
clc
    stats = getStats; %get data
    params = struct('name',{'e','alpha','beta','tau0'}); %description of parameters
    perms = [1 2;1 3;1 4;
             2 1;2 3;2 4;
             3 1;3 2;3 4;
             4 1;4 2;4 3];%all permutations
    
    disp('_________________Correlation Relations__________________')
    fid = fopen('correlation_relations.txt','w');
    for permN = 1:length(perms(:,1))
        c1 = perms(permN,1);
        c2 = perms(permN,2);
        disp('___________________')
        
        fprintf(fid,'[%s, %s]\r\n#\t\tRo\t\tn\t\ts\r\n',params(c1).name,params(c2).name);
        for task = 1:length(stats)
            [d,s] = correl(sortrows([stats(task).params(:,c1) stats(task).params(:,c2)],1));
            disp(sprintf('Task#%d : d(%s,%s) = %g',task,params(c1).name,params(c2).name,d))
            
            %alpha = 0.1/2;
            n = length(stats(task).params(:,c2));
            %f_st = abs(d)*sqrt((n - 2)/(1 - d * d));
            fprintf(fid,'%d\t\t%g\t\t%d\t\t%d\r\n',task,d,n,s);
        end
    end
    fclose(fid);
    
end

function [d,s] = correl(darr)
    x = darr(:,1); %significant variable
    y = darr(:,2); %non-significant variable
    
    %get groups of elements
    c = 1;
    cells = {};lengths = {};
    pk = 1;
    for k = 1:length(x) - 1
        if (x(k) ~= x(k + 1))
            cells{c} = [x(pk:k) y(pk:k)];
            lengths{c} = (k - pk) + 1;
            pk = k + 1;
            c = c + 1;
        end
        if k + 1 == length(x)
            cells{c} = [x(pk:k+1) y(pk:k+1)];
            lengths{c} = (k + 1 - pk) + 1;
        end
    end
    groups = struct('val',cells,'length',lengths);
      
    y_av = 0;
    for k = 1:length(groups)
        groups(k).y_av = sum(groups(k).val(:,2))/groups(k).length;
        y_av = y_av + groups(k).length*groups(k).y_av;
    end
    y_av = y_av/length(x);
    
    Sy_av = 0;
    for k = 1:length(groups)
        Sy_av = Sy_av + groups(k).length*((groups(k).y_av - y_av)^2);
    end
    Sy_av = Sy_av/length(x);
    
    Sy = 0;
    for k = 1:length(groups)
        for i = 1:size(groups(k).val,1)
            Sy = Sy + (groups(k).val(i,2) - y_av)^2;
        end
    end
    Sy = Sy/length(x);
   
    d = sqrt(Sy_av/Sy);
    s = length(groups);
end

