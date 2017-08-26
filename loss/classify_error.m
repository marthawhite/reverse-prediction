function err = classify_error(Yu, Output)

[a, b] = size(Yu);

Yr = roundY(Output);
%[m,P] = align(Yu,Yr);
%Yr = round(Yr*P);
err = sum(sum(abs(Yu - Yr),2) > 0) / a;

end

