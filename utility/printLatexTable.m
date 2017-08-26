function printLatexTable(results, fileId, ignoreBad)
% Bold the entries that are statistically significantly different
  
  if nargin < 2
    fileId = 1;
  end
  if nargin < 3 || length(results.opts.DataNames) > 1
    ignoreBad = 0;
  end
  
  numAlgs = length(results.opts.AlgNames);
  numData = length(results.opts.DataNames);
  errInd = 1;
  fprintf(fileId, '\\begin{table*}[t]\n\\begin{center}\n\\begin{sc}\n\\begin{tabular}{l|');
  for i = 1:numData
    fprintf(fileId, '|c');
  end
  fprintf(fileId, '}\\\\ \\hline ');
  for i = 1:numData
    fprintf(fileId, '& %s ', results.opts.DataNames{i});
  end
  
  totalErr = results.totalErr;
  summedErr = results.summedErr;
  summedErr_std = results.summedErr_std;
  num_repetitions = results.opts.num_repetitions;
  if ignoreBad == 1
    dg = 1;
     ind = [];
     for rep = 1:results.opts.num_repetitions
         minVal = min(results.totalErr(dg, :, errInd, rep));
         if minVal*5 > max(results.totalErr(dg, :, errInd, rep))
             ind = [ind rep];
         end
     end
     
    num_repetitions = length(ind);
    totalErr = results.totalErr(dg, :,:,ind);
    summedErr(dg,:,:) = sum(totalErr(dg,:,:,:),4)/num_repetitions;
    summedErr_std(dg,:,:) = sqrt(sum(totalErr(dg,:,:,:).^2,4)/num_repetitions - ...
                                 summedErr(dg,:,:).^2);
    fprintf(1,'printLatexTable -> Started with %d reps, ended with %d reps\n', results.opts.num_repetitions, num_repetitions);
  end
  
  % Determine if any of the differences are statistically different
  algIndices = checkSignificance(totalErr);
  fprintf(fileId,'\\\\');
  for a = 1:numAlgs
  	fprintf(fileId, '\\hline %s ', results.opts.AlgNames{a});
    for dg = 1:numData
      if algIndices(dg,a) == 1
        fprintf(fileId, ' & {\\bf %.4g $\\pm$ %.4g}',summedErr(dg,a,errInd), summedErr_std(dg,a,errInd)/ sqrt(num_repetitions));      
      else
        fprintf(fileId, ' & %.4g $\\pm$ %.4g',summedErr(dg,a,errInd), summedErr_std(dg,a,errInd)/ sqrt(num_repetitions));
      end
  	end    
  	fprintf(fileId,'\\\\ \n');
  end
  fprintf(fileId,'\\hline \\end{tabular} \\end{sc} \\end{center}\\caption{Algorithms on}\n\\end{table*}\n');
  
  function algIndices = checkSignificance(errors)
    % Report ties
    algIndices = zeros(numData,numAlgs);
    tolerance = 1e-2;
    for dg = 1:numData
      errs = sum(errors(dg,:,errInd,:),4)/num_repetitions;
      % Take the minimum alg error and then compare to rest
      [minVal,minAlg] = min(errs);
      minAlgs = (errs <= minVal+tolerance);
      sig = 1;
      for alg = 1:numAlgs 
        if minAlgs(alg) == 1, continue; end
        [h,p] = ttest(errors(dg,minAlg,errInd,:), errors(dg,alg,errInd,:));
        if h == 0
          sig = 0;
        end
      end
      if sig ~= 0
        algIndices(dg,minAlgs) = 1;
      end
    end
end

end