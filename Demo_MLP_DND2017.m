clear;
addpath 'C:\Users\csjunxu\Desktop\JunXu\Paper\Image Video Denoising\MLP CVPR2012\MLP\model';

Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\images_srgb\';
fpath = fullfile(Original_image_dir, '*.mat');
im_dir  = dir(fpath);
im_num = length(im_dir);
load 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\info.mat';

method = 'MLP';
% write image directory
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/dnd_2017Results/'];
write_sRGB_dir = [write_MAT_dir method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

nSig = 10;
RunTime = [];
for i = 1 : im_num
    Par.image = i;
    load(fullfile(Original_image_dir, im_dir(i).name));
    S = regexp(im_dir(i).name, '\.', 'split');
    [h,w,ch] = size(InoisySRGB);
    for j = 1:size(info(1).boundingboxes,1)
        IMname = [S{1} '_' num2str(j)];
        fprintf('%s: \n', IMname);
        %         bb = info(i).boundingboxes(j,:);
        %         IM = InoisySRGB(bb(1):bb(3), bb(2):bb(4),:);
        IM = double(imread([Original_image_dir '/' IMname '.png']));
        IM_GT = IM;
        time0 = clock;
        model = {};
        % width of the Gaussian window for weighting output pixels
        model.weightsSig = 2;
        % the denoising stride. Smaller is better, but is computationally
        % more expensive.
        model.step = 3;
        IMout = zeros(size(IM));
        for c = 1:ch
            %% denoising
            IMoutcc = fdenoiseNeural(IM(:,:,c), nSig, model);
            IMout(:,:,c) = IMoutcc;
        end
        RunTime = [RunTime etime(clock,time0)];
        fprintf('Total elapsed time = %f s\n', (etime(clock,time0)) );
        IMoutname = sprintf([write_sRGB_dir '/' method '_DND_nSig_' num2str(nSig) '_' IMname '.png']);
        imwrite(IMout/255, IMoutname);
    end
end