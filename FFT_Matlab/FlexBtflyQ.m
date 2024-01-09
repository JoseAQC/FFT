function [dataoutQ]= FlexBtflyQ (N, datain, W)

dataout= [];
q_out = quantizer('fixed','floor', 'wrap', [21 11]);

dataoutQ = quantize(q_out, dataout);
for m=1:N/2
    dataoutQ(m)= datain(m) + datain(N/2+m);
end;

dataoutQ = quantize(q_out, dataoutQ);
for m=N/2+1:N
    dataoutQ(m)= (datain(m-N/2) - datain(m))*W(m-N/2);
end;
dataoutQ = quantize(q_out, dataoutQ);