function [area, rocPointX, rocPointY] = rocCurve(outputs, labels,display)
[sOutputs, index] = sort(outputs);
sLabels = labels(index);
rocPointY = cumsum(sLabels==-1)/sum(labels==-1);
rocPointX = cumsum(sLabels==1)/sum(labels==1);
if nargin < 3
  plot(rocPointX, rocPointY);
end
area = trapz(rocPointX, rocPointY);
