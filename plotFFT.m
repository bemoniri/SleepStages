function [] = plotFFT( y, Fs, inf, sup, titlestr, ylabelstr, ysup )
Y1 = fft(y);
L = length(Y1);
P2 = abs(Y1/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

plot(f, P1)
title(titlestr)
xlabel('f (Hz)')
ylabel(ylabelstr)
xlim([inf,sup]);
ylim([0,ysup]);
end

