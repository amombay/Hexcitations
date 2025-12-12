function dtheta = theta_dot(theta, sigma, tau, N)
    A = zeros(N,N);
    b = zeros(N,1);

    sum_sin = sum(sin(theta(1) - theta));
    A(1,1) = tau * N;
    
        for j = 2:N
            A(1,j) = tau * (N-j+1)*(cos(theta(1) - theta(j)));
        end
        b(1) = - (2*theta(1) - theta(2) - sigma * sum_sin);

    for i = 2:N-1
        sum_sin = sum(sin(theta(i) - theta(i:N)));
        for j = 1:i
            A(i,j) = tau * (N-i+1) * cos(theta(i) - theta(j));
        end
        for j = i+1:N
            A(i,j) = tau * (N-j+1) * cos(theta(i) - theta(j));
        end
        b(i) = - (2*theta(i) - theta(i-1) - theta(i+1) - sigma*sum_sin);
    end

       for j = 1:N
            A(N,j) = tau*cos(theta(N) - theta(j));
       end
    b(N) = - (theta(N) - theta(N-1));
    dtheta = A\b;
end