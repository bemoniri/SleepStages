function h = BPF(L,lowF,higF,FS)
    %{
        Inputs:
            L: Lenght of filter
            lowF: Low frequency
            higF: High frequency
            FS: Sampling frequency
        Outut:
            h: Impulse response of the filter
    %}
    beta = 3;
    h = fir1(L-1,[2*lowF/FS,2*higF/FS], kaiser(L,beta));
    h = h(:);
    
    figure
    freqz(h)
end


