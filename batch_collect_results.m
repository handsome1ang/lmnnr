% options: 
features_types = {'rgb+hsv','hsv','rgb'};
corrections = {'colorcrc','orig'};
num_pcs = [20 40 60];
num_splits = 10;

results_dir = '../submitted_results';
result_name_format = 'split%02d_%s_%s_pc%2d_%s';


results = 0;

% for each split, do: 
for i=1:num_splits
    % feature type
    for f=1:length(features_types)
        % color correction or not
        for c=1:length(corrections)
            % num pcs
            for p=1:length(num_pcs)
                
                load(fullfile(results_dir, ...
                    sprintf(result_name_format,i,features_types{f}, ...
                    corrections{c}, num_pcs(p), 'nolearning')), ...
                    'distances', 'cmc');
                
                results(i,f,c,p,1) = sum(cmc)/length(cmc);
                
                
                load(fullfile(results_dir, ...
                    sprintf(result_name_format,i,features_types{f}, ...
                    corrections{c}, num_pcs(p), 'learning1')), ...
                    'distances', 'cmc', 'M');
                results(i,f,c,p,2) = sum(cmc)/length(cmc);
                
                
                load(fullfile(results_dir, ...
                    sprintf(result_name_format,i,features_types{f}, ...
                    corrections{c}, num_pcs(p), 'learning2')), ...
                    'distances', 'cmc', 'M');
                results(i,f,c,p,3) = sum(cmc)/length(cmc);
            end
        end
    end
end


%% statistics
mean_results = squeeze(mean(results, 1));
std_results = squeeze(std(results, 1));
[foo,idxs] = sort(mean_results(:),'descend');
for i=idxs'
    [f,c,p,x] = ind2sub(size(mean_results), i);
    fprintf('%s\t%d\t%d\t%d\t%f+-%f\n',features_types{f}, c, ... 
        num_pcs(p), x,mean_results(i), std_results(i));
end

%% find the best result w.r.t. to the normalized area under cmc
learning_methods = {'nolearning','learning1','learning2'};
[foo,idx] = max(results(:));
[i,f,c,p,x] = ind2sub(size(results), idx);
fprintf('Best performance %.2f obtained at split %d, %s, %s, %d, %s\n',...
    100*foo, i, features_types{f}, corrections{c}, num_pcs(p), ...
    learning_methods{x});


%% plot CMC
load(fullfile(results_dir, sprintf(result_name_format,i, ...
    features_types{f}, corrections{c}, num_pcs(p), learning_methods{x})));
plot(100*cmc,'-+');
grid on
xlabel('Rank score');
ylim([0 101]);
xlim([1 length(cmc)]);
ylabel('Recognition Percentage');
title('Cumulative Matching Characteristic (CMC) Curve');

figure
img = imread('previous_cmcs.png');
imshow(img);
hold on
xnew = ((239-161)/50)*((1:length(cmc))-50)+161;
ynew = ((38-237)/50)*(100*cmc-50)+237;
plot(xnew, ynew, '-d','Color',[255 165 0]/255)

%% plot reidentification rate
N = length(cmc);
reirate = [];
for M=1:25
    rank = round(N/M);
    reirate(M) = 100*cmc(rank);
end
open('reirate_previous_results.fig');
hold on
plot(reirate,'-d','Color',[255 165 0]/255)
legend('ELF 200','Principal Axis Histogram','Hand Localized Histogram',...
    'Histogram','Template','Chance','LMNN-R');


%% create latex table for average area-under-CMC values
mean_results = squeeze(mean(100*results, 1));
std_results = squeeze(std(100*results, 1));

for p=1:length(num_pcs)
    for x=1:length(learning_methods)
        fprintf('$%d$ & %s ',num_pcs(p),learning_methods{x});
        for f=1:length(features_types)
            for c=1:length(corrections)
                fprintf('& $%.2f \\pm %.2f$  ',mean_results(f,c,p,x), ...
                    std_results(f,c,p,x));
            end
        end
        fprintf('\\\\ \n');
    end
end

%% produce ROC for LMNN and LMNN-R
figure
r1 = [];  r2 = []; interp1 = []; interp2 = [];
x = 0:0.01:1;
for i=1:10
    load(sprintf('../submitted_results/split%02d_rgb+hsv_orig_pc60_learning1.mat',i));
    d1 = distances;
    load(sprintf('../submitted_results/split%02d_rgb+hsv_orig_pc60_learning2.mat',i));
    d2 = distances;
    r1(:,:,i) = get_roc_curve(d1);
    r2(:,:,i) = get_roc_curve(d2);
    %     figure
    %     plot(r1(:,2), r1(:,1),'b-+', r2(:,2), r2(:,1),'r-+');
    
    for j=1:length(x)
        [foo,idxs] = sort(abs(r1(:,2,i)-x(j)));
        d1 = abs(r1(idxs(1),2,i)-x(j));
        d2 = abs(r1(idxs(2),2,i)-x(j));
        
        if d1==0 
            interp1(i,j) = r1(idxs(1),1,i);
        elseif d2==0
            interp1(i,j) = r1(idxs(2),1,i);
        else
            interp1(i,j) = (1/(d1+d2))*(d1*r1(idxs(1),1,i) + d2*r1(idxs(1),1,i));
        end
        
        
        [foo,idxs] = sort(abs(r2(:,2,i)-x(j)));
        d1 = abs(r2(idxs(1),2,i)-x(j));
        d2 = abs(r2(idxs(2),2,i)-x(j));
        
        if d1==0
            interp2(i,j) = r1(idxs(1),1,i);
        elseif d2==0
            interp2(i,j) = r1(idxs(2),1,i);
        else
            interp2(i,j) = (1/(d1+d2))*(d1*r2(idxs(1),1,i) + d2*r2(idxs(1),1,i));
        end
    end
end

interp1 = mean(interp1);
interp2 = mean(interp2);

plot(x,interp1,'b--', x,interp2, 'r-');
grid on
title('ROC');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
axis([0 0.25 .5 1])
legend('LMNN','LMNN-R','location','southeast');
