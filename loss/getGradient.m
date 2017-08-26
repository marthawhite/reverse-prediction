function g = getGradient(X,Y,U,Xhat,var)

    % only include g if var > 0
    g = 0;
    if var > 0
        if var == 2
            g = Y'*(Xhat - X);
        else
            g = (Xhat - X)*U';
        end
    end

end
