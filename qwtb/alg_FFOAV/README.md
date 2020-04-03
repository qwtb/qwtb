# Fast-Parallel-Fully-Overlapped-Allan-Variance-and-Total-Variance
Code for the fast, parallel algorithm for Fully Overlapped Allan Variance and Total Variance developed in [1]:

## Description
Modelling stochastic noise in inertial sensors-particularly those used in guidance, navigation and control applications-involves characterising the underlying noise process by inferring parameters such as random walks and drift rates from the Allan Deviation plots. Fully Overlapped Allan Variance and Total Variance are two methods that accurately derive these parameters by observing all possible time averages, but existing implementations are computationally expensive: they require $\Theta(N^3)$ time for processing N data points (Section III). Thus, several methods have been developed to trade accuracy in parameter estimates for reduced computational effort, including Not Fully Overlapped Allan Variance which runs in $\Theta(N^2)$  time. Our key contribution is a fast, parallelizable algorithm (Algorithm. 1) to calculate Fully Overlapped Allan Variance and Total Variance for generating smooth Allan Deviation plots whose serial running time is $\Theta(N^2)$, and we demonstrate improved execution times with parallel implementations. Our fast algorithm thus enables Fully Overlapped Allan Variance and Total Variance to be the norm for estimating Allan Variance parameters efficiently and with high confidence

## References
[1] S. M. Yadav, S. K. Shastri, G. B. Chakravarthi, V. Kumar, D. R. A and V. Agrawal, "A Fast, Parallel Algorithm for Fully Overlapped Allan Variance and Total Variance for Analysis and Modelling of Noise in Inertial Sensors," in IEEE Sensors Letters.
doi: 10.1109/LSENS.2018.2829799
URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8345576&isnumber=7862766
keywords: {Clustering algorithms;Instruction sets;Matlab;Random access memory;Sensors;Stochastic processes;TV;Allan Variance;Inertial sensors;Sensor noise modelling and analysis;Stochastic errors}

## Contact
Shrikanth M. Yadav ( shrikanth_yadav@outlook.com ), Saurav K. Shastri ( sauravks1996@gmail.com ), Ghanshyam B. Chakravarthi ( ghanashyam.chakravarthi@gmail.com ).
