%--------------------------------------------------------------------------
clear;
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.png');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\our_Results\Real_MeanImage\';
GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\our_Results\Real_NoisyImage\';
TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');

GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

addpath 'model';
method = 'MLP';
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/CVPR2017/our_Results/'];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

for nSig     =  [10]
    format compact;
    PSNR = [];
    SSIM = [];
    for i = 1 : im_num
        IM =   double(imread( fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
        IM_GT = double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
        S = regexp(TT_im_dir(i).name, '\.', 'split');
        IMname = S{1};
        [h,w,ch] = size(IM);
        %         randn('seed',0);
        %         noise_img          =   I+ nSig*randn(size(I));
        %         noise_img = double(uint8(noise_img));
        model = {};
        % width of the Gaussian window for weighting output pixels
        model.weightsSig = 2;
        % the denoising stride. Smaller is better, but is computationally
        % more expensive.
        model.step = 3;
        IMout = zeros(size(IM));
        for cc = 1:ch
            %% denoising
            IMoutcc = fdenoiseNeural(IM(:,:,cc), nSig, model);
            IMout(:,:,cc) = IMoutcc;
        end
        PSNR = [PSNR csnr( uint8(IMout), uint8(IM_GT), 0, 0 )];
        SSIM = [SSIM cal_ssim( uint8(IMout), uint8(IM_GT), 0, 0 )];
        fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
        imwrite(IMout/255, [write_sRGB_dir 'Real_' method '/' method '_our' num2str(im_num) '_' IMname '.png']);
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    save(['C:/Users/csjunxu/Desktop/CVPR2017/our_Results/', method, '_our' num2str(im_num) '.mat'],'PSNR','mPSNR','SSIM','mSSIM');
end