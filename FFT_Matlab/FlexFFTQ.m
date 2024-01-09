function [dataoutf]= FlexFFTQ (N, datain)

Nstage= log2(N);


for n=0:N/2-1
    W(n+1)= exp(1)^(-n*i*2*pi/N);
end;

%cuantificacion de la señal de entrada
q_coef = quantizer('fixed', 'floor', 'wrap', [16 14]);
W_q = quantize(q_coef, W);
%

q_in = quantizer('fixed', 'floor', 'wrap', [21 11]); %Q10.11
dataoutQ = quantize (q_in, datain);

for m=1:Nstage
    if m==Nstage
        W_q= ones(size(W_q));
    end;
    %waux=W(1:(2^(m-1)):N/2);
    for n=1:(2^(m-1))
        dataoutQ((n-1)*N/(2^(m-1))+1:(n)*N/(2^(m-1)))= FlexBtflyQ (N/(2^(m-1)), dataoutQ((n-1)*N/(2^(m-1))+1:(n)*N/(2^(m-1))), ...
            W_q(1:(2^(m-1)):N/2));
    end;
end;



dataoutf= dataoutQ;
for m=1:length(dataoutQ)
    dataoutf(bin2dec(fliplr(dec2bin(m-1,Nstage)))+1)= dataoutQ(m);
end;
