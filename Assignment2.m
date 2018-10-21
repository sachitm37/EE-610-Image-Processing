%while 1
close all
clear all

%Read Images
og=readimage();
degimg=readimage();
kernel=readimage();
kernel = double(kernel)/sum(sum(kernel));       %Normalizing the kernel to prevent blowing up of values

if numel(size(degimg)) == 3					%To deal with rgb images
	imghsv = rgb2hsv(degimg);
	V = 255.0*imghsv(:,:,3);				% Since rgb's V values are between 0 and 1
else
	V = degraded_img;						% Grayscale Images
end
[m,n] = size(V);
m2 = pow2(nextpow2(m));                     %size should be a power of 2 for fft algorithm
n2 = pow2(nextpow2(n));
[mkernel,nkernel]=size(kernel);
    
padded_degimg = zeros(m2,n2);           %Resizing kernel and degraded image for fourier algorithm
padded_degimg(1:m,1:n) = V;
padded_kernel = zeros(m2,n2);
padded_kernel(1:mkernel,1:nkernel) = kernel;
kerDFT = fftshift(fft2(padded_kernel));
kerDFT = kerDFT + 0.000001;
degDFT = fftshift(fft2(padded_degimg));

while 1
%Display images
figure(1)                                         %displaying original and degradd images
subplot(131),imshow(og),title('Original Image')
figure(1) 
subplot(132),imshow(degimg),title('Degraded Image')

ip = input('1 for inverse filtering \n2 for Truncated Inverse Filtering \n3 for Weiner Filtering \n4 for Constrained Least Squares Filtering: ');

% Inverse Filtering
if ip==1
	newDFT = degDFT./kerDFT;

% Truncared Inverse Filtering
elseif ip==2
	radius = input('Enter radius : ');
    newDFT = degDFT./kerDFT;
    xrange=1:m2;
    yrange=1:n2;
    xrange = xrange-((m2+1)/2);
    yrange = yrange-((n2+1)/2);
    [xgraph,ygraph]=ndgrid(xrange,yrange);              %Generating range of frequencies(u,v)
    LPF=(xgraph.^2 + ygraph.^2 <= radius^2);            %Low pass filter
	newDFT = abs(newDFT).*LPF.*exp(1i*angle(newDFT));

% Wiener Filtering
elseif ip==3
	k = input('Enter K : ');
    newDFT = conj(kerDFT).*degDFT./(abs(kerDFT).^2 + k*ones(m2,n2));

% Constrained Least Squares Filtering	
elseif ip==4
	gamma = input('Enter gamma : ');
    P = [0 -1 0; -1 4 -1; 0 -1 0];              %Laplacian Operator
	padded_P = zeros(m2,n2);
    padded_P(1:3,1:3) = P;
	P_DFT = fftshift(fft2(padded_P));	
    newDFT = conj(kerDFT).*degDFT./(abs(kerDFT).^2 + gamma*P_DFT);	
end

% Take inverse FFT
new = abs(ifft2(fftshift(newDFT)));
new = new(1:m, 1:n);
if numel(size(degimg)) == 3								% RGB Images
	imghsv(:,:,3) = new/255.0;
	new = uint8(255*hsv2rgb(imghsv));
end
figure(1)
subplot(133),imshow(new),title('Reconstructed Image')
ip1=input('Press 1 to exit, any other key to continue: ');
PSNR=psnr(og,new)
SSIM=ssim(og,new)
if(ip1==1)
    break
end
end
close all