function cm=confusion(pred,true);
 classes=unique(true);
 cm=zeros(length(classes));
 for i=1:length(classes)
     for j=1:length(classes)
  cm(i,j)=sum(true==classes(i) & pred==classes(j));    
   end
end
