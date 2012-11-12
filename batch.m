% options: 
features_types = {'rgb+hsv','hsv','rgb'};
corrections = {'colorcrc','orig'};
num_pcs = [20 40 60];
num_splits = 10;

results_dir = '../submitted_results';
result_name_format = 'split%02d_%s_%s_pc%2d_%s';



% for each split, do: 
for i=1:num_splits
    split = load(sprintf('../submitted_results/split_%02d',i));

    % feature type
    for f=1:length(features_types)
        % color correction or not
        for c=1:length(corrections)
            % num pcs
            for p=1:length(num_pcs)
                [dists1,dists2, dists3, cmc1, cmc2, cmc3, M2, M3] = ...
                train_test_allmethods(split, features_types{f}, ...
                        corrections{c}, num_pcs(p));

                % save results
                distances = dists1;
                cmc = cmc1;
                save(fullfile(results_dir, ...
                    sprintf(result_name_format,i,features_types{f}, ...
                        corrections{c}, num_pcs(p), 'nolearning')), ...
                        'distances', 'cmc');

                distances = dists2;
                cmc = cmc2;
                M = M2;
                save(fullfile(results_dir, ...
                    sprintf(result_name_format,i,features_types{f}, ...
                        corrections{c}, num_pcs(p), 'learning1')), ...
                        'distances', 'cmc', 'M');

                distances = dists3;
                cmc = cmc3;
                M = M3;
                save(fullfile(results_dir, ...
                    sprintf(result_name_format,i,features_types{f}, ...
                        corrections{c}, num_pcs(p), 'learning2')), ...
                        'distances', 'cmc', 'M');
            end
        end
    end
end
