% Creates N random train/test/ab split for the VIPER dataset, and saves them
% under OUTDIR. 
N = 10;
OUTDIR = '../submitted_results';

params = set_params; 


if exist(fullfile(OUTDIR, sprintf('split_%02d.mat',1)),'file')
    r = input(['WARNING: Some previous split file exist.\n ' ...
        ' Do you want to continue and overwrite them? (1 or 0)']);

    if r==0
        return;
    end
end

for i=1:N
    outfilename = fullfile(OUTDIR, sprintf('split_%02d.mat',i));

    fprintf('Generating %s\n', outfilename);

    ab = randi(2,params.num_images, 1)-1;
    
    tmp = randperm(params.num_images)';

    half = round(params.num_images/2);

    train_ind = tmp(1:half);
    test_ind = tmp(half+1:end);

    save(outfilename, 'train_ind', 'test_ind', 'ab');
end
