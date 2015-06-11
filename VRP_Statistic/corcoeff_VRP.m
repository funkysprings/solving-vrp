function corcoeff_VRP
clc
    stats = getStats; %get data
    params = struct('name',{'e','alpha','beta','tau0'}); %description of parameters
    perms = [1 2;1 3;1 4;
             2 3;2 4;
             3 4];%all permutations
    
    disp('_________________Coefficient of Correlation__________________')
    fid = fopen('correlation_coefficients.txt','w');
    for permN = 1:length(perms(:,1))
        c1 = perms(permN,1);
        c2 = perms(permN,2);
        disp('___________________')
        
        fprintf(fid,'[%s, %s]\r\n#\t\tDet\t\tn\r\n',params(c1).name,params(c2).name);
        for task = 1:length(stats)
            d = corcoeff([stats(task).params(:,c1) stats(task).params(:,c2)]);
            disp(sprintf('Task#%d : r(%s,%s) = %g',task,params(c1).name,params(c2).name,d))
            
            %alpha = 0.1/2;
            n = length(stats(task).params(:,c2));
            %t_st = abs(d)*sqrt((n - 2)/(1 - d * d));
            fprintf(fid,'%d\t\t%g\t\t%d\r\n',task,d,n);
        end
    end
    fclose(fid);

end

function r = corcoeff(arr)
    x = arr(:,1);
    y = arr(:,2);
    n = length(x);
    
    sxy = 0;
    sx = 0; sy = 0;
    for i = 1:n
        sxy = sxy + x(i)*y(i);
        sx = sx + x(i)*x(i);
        sy = sy + y(i)*y(i);
    end
    nom = n * sxy - sum(x) * sum(y);
    denom = sqrt((n * sx - (sum(x))^2) * (n * sy - (sum(y))^2));
    
    r = nom/denom;
end

function dzn = test_corcoeff(alpha, d, n)
    t_st = abs(d)*sqrt((n - 2)/(1 - d * d)); %!
    alpha1 = alpha/2; %!
    n1 = n - 2; %!
    dzn = t_st; %
    

end

