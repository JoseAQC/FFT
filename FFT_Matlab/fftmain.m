%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% fftmain.m
%
% It analyses the quantization effects on s standard FFT.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program control variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CTRL_show_figs= true;
CTRL_mode_chk= true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = 62.5e6;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for FFT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nfft= 512;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input generation
tones= [2e6 5e6 9e6 12e6];
amplitude= 0.5;
[t, finput]= genInput (amplitude, tones, Nfft, fs);


fidh= fopen ('DataIn.h', 'w+');
fprintf (fidh, 'sampleOutX_t DataIn[FFT_LENGTH]= {');
for n=1:length(finput)-1,
    fprintf (fidh, 'std::complex<float>(%f,%f), ', real(finput(n)), imag(finput(n)));
end;
fprintf (fidh, 'std::complex<float>(%f,%f)};\n\n', real(finput(end)), imag(finput(end)));
fclose (fidh);

if CTRL_show_figs==false
    figure;
    t=[0:length(finput)-1];
    t= t/500e3;
    plot(t, finput);
    xlabel('Samples');
    ylabel('Amplitude');
    title ('Input signal, floating-point');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Floating-point FFT computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% f= [-Nfft/2:Nfft/2-1]*fs/Nfft;
% 
% foutputi= fft (finput(1:Nfft), Nfft);
% foutput= abs (foutputi);
% foutput= fftshift (foutput);
% foutputi= fftshift (foutputi);
% 
% if CTRL_show_figs==true
%     figure;
%     subplot (2, 1, 1); plot (finput(1,1:Nfft));
%     xlabel ('Time (s)');
%     title ('First frame FFT, floating-point');
%     subplot (2, 1, 2); stem (f,foutput);
%     xlabel ('Frequency (Hz)');
% end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flexible Floating-point FFT computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f= [-Nfft/2:Nfft/2-1]*fs/Nfft;

fxoutputi= FlexFFT (Nfft, finput(1:Nfft));
fxoutput= abs (fxoutputi);
fxoutput= fftshift (fxoutput);
fxoutputi= fftshift (fxoutputi);


fxoutputiQ = FlexFFTQ (Nfft, finput(1:Nfft));
fxoutputQ = abs(fxoutputiQ);
fxoutputQ= fftshift (fxoutputQ);
fxoutputiQ= fftshift (fxoutputiQ);


if CTRL_show_figs==true
    figure;
    subplot (2, 2, 1); plot (finput(1,1:Nfft));
    xlabel ('Time (s)');
    title ('First frame FFT, flexible floating-point');
    subplot (2, 2, 3); stem (f,fxoutput);
    xlabel ('Frequency (Hz)');
    subplot (2, 2, 2); plot (finput(1,1:Nfft));
    xlabel ('Time (s)');
    title ('First frame FFT, flexible fixed-point');
    subplot (2, 2, 4); stem (f,fxoutputQ);
    xlabel ('Frequency (Hz)');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flexible Error analysis between floating-point and fixed-point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error= abs (fxoutput - fxoutputQ);

error = (error/(max(fxoutput)))*100;

if CTRL_show_figs==true
    figure;
    stem (f, error);
    title ('Flexible - floating-point First frame FFT error');
end;

mx= max (max (max (error)));
s= sprintf ('\nMaximum absolute error in FFT quantization: %f.\n', mx);
disp (s);

