% convert to hsv
close all;fclose all;clc;clear all;
params = set_params();

colorcrc = true;

fprintf('camera a\n');
if colorcrc
    source_file = [params.all_viper_cam_a(1:end-4), '_colorcrc.mat'];
else
    source_file = params.all_viper_cam_a;
end

fprintf('reading: %s\n',source_file);
load(source_file);

images_a_hsv = zeros(size(images_a));
for i = 1:params.num_images,
    cur_im = squeeze(images_a(i,:,:,:)/255);
    images_a_hsv(i,:,:,:) = rgb2hsv(cur_im);
end

if colorcrc
    target_file = fullfile(params.data_dir, 'cam_a_hsv_colorcrc.mat');
else
    target_file = fullfile(params.data_dir, 'cam_a_hsv.mat');
end
fprintf('writing: %s\n',target_file);
save(target_file,'images_a_hsv'); 

%same thing camera b

fprintf('camera b\n');
if colorcrc
    source_file = [params.all_viper_cam_b(1:end-4), '_colorcrc.mat'];
else
    source_file = params.all_viper_cam_b;
end
fprintf('reading: %s\n',source_file);
load(source_file);

images_b_hsv = zeros(size(images_b));

for i = 1:params.num_images,
    cur_im = squeeze(images_b(i,:,:,:)/255); 
    images_b_hsv(i,:,:,:) = rgb2hsv(cur_im);
end

if colorcrc
    target_file = fullfile(params.data_dir, 'cam_b_hsv_colorcrc.mat');
else
    target_file = fullfile(params.data_dir, 'cam_b_hsv.mat');
end
fprintf('writing: %s\n',target_file);
save(target_file,'images_b_hsv'); 
