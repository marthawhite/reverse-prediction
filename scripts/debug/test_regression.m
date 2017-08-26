cd ../
initialize_matlab
cd debug

tl = 900;
tt = 1000;

% For one dimensional data, the corresponding transfers should work
% almost perfectly

% Test Euclidean data
[X_euc,Y_euc,U] = genRevGaussian(tt,1,1,struct('sigma', 0, 'gen_reals', 1));
Xl = X_euc(1:tl, :); Yl = Y_euc(1:tl, :);
Xu = X_euc(tl+1:tt, :); Yu = Y_euc(tl+1:tt, :);
[Z_euc, W_euc, U_euc, flag] = RegressionSemi(Xl, Yl, Xu, struct('transfer', 'Euclidean'));
err1 = regression_error(Yu, Z_euc);
if err1 > 0.01
    fprintf(1, 'test -> Did not pass test for transfer Euc with error: %g\n', err1);
end

% Test Cube data
[X_cube,Y_cube,U] = genRevCube(tt,1,1,struct('sigma', 0));
Xl = X_cube(1:10, :); Yl = Y_cube(1:10, :);
Xu = X_cube(tl+1:tt, :); Yu = Y_cube(tl+1:tt, :);
[Z_cube, W_cube, U_cube, flag] = RegressionSemi(Xl, Yl, Xu, struct('transfer', 'Cube'));
err2 = regression_error(Yu, Z_cube);
if err2 > 0.01
    fprintf(1, 'test -> Did not pass test for transfer Cube with error: %g\n', err2);
end

% Test Exp data
[X_exp,Y_exp,W] = genForExp(tt,1,1,struct('sigma', 0));
Xl = X_exp(1:tl, :); Yl = Y_exp(1:tl, :);
Xu = X_exp(tl+1:tt, :); Yu = Y_exp(tl+1:tt, :);
[Z_exp, W_exp, U_exp, flag] = RegressionSemi(Xl, Yl, Xu, struct('transfer', 'Exp'));
err3 = regression_error(Yu, Z_exp);
if err3 > 0.01
    fprintf(1, 'test -> Did not pass test for transfer Exp with error: %g\n', err3);
end

% Test Exp data using all data as labeled data
%[X_exp,Y_exp,W] = genForExp(tt,1,1,struct('sigma', 0));
[Z_exp, W_exp, U_exp, flag] = Regression(Xl, Yl, Xu, struct('transfer', 'Exp'));
err4 = regression_error(Yu, Z_exp);
if err4 > 0.01
    fprintf(1, 'test -> Did not pass test on labeled data for transfer Exp with error: %g\n', err3);
end

err1
err2
err3
err4
