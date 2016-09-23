%--------------------------------------------------------------------------
clear;
GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
GT_fpath = fullfile(GT_Original_image_dir, '*.png');
CC_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
CC_fpath = fullfile(CC_Original_image_dir, '*.png');
GT_im_dir  = dir(GT_fpath);
CC_im_dir  = dir(CC_fpath);
im_num = length(CC_im_dir);

method           =  'MLP';
nSig     =  [25];
format compact;

PSNR = [];
SSIM = [];
for i = 1:im_num
    IM =   im2double(imread( fullfile(CC_Original_image_dir,CC_im_dir(i).name) ));
    IM_GT = im2double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
    S = regexp(CC_im_dir(i).name, '\.', 'split');
    IMname = S{1};
    [h,w,ch] = size(IM);
    % color or gray image
    if ch==1
        IMin_y = IM;
    else
        % change color space, work on illuminance only
        IMin_ycbcr = rgb2ycbcr(IM);
        IMin_y = IMin_ycbcr(:, :, 1);
        IMin_cb = IMin_ycbcr(:, :, 2);
        IMin_cr = IMin_ycbcr(:, :, 3);
    end
    %         randn('seed',0);
    %         noise_img          =   I+ nSig*randn(size(I));
    %         noise_img = double(uint8(noise_img));
    model = {};
    % width of the Gaussian window for weighting output pixels
    model.weightsSig = 2;
    % the denoising stride. Smaller is better, but is computationally
    % more expensive.
    model.step = 3;
    
    IMout_y = fdenoiseNeural(IMin_y*255, nSig, model);
    if ch==1
        IMout = IMout_y/255;
    else
        IMout_ycbcr = zeros(size(IM));
        IMout_ycbcr(:, :, 1) = IMout_y/255;
        IMout_ycbcr(:, :, 2) = IMin_cb;
        IMout_ycbcr(:, :, 3) = IMin_cr;
        IMout = ycbcr2rgb(IMout_ycbcr);
    end
    PSNR = [PSNR csnr( IMout*255, IM_GT*255, 0, 0 )];
    SSIM = [SSIM cal_ssim( IMout*255, IM_GT*255, 0, 0 )];
    imwrite(IMout, ['C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_' method '\' method '_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
save(['C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\', method, '_CCNoise.mat'],'nSig','PSNR','mPSNR','SSIM','mSSIM');