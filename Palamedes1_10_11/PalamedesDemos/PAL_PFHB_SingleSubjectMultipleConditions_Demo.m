%
%PAL_PFHB_SingleSubjectsMultipleConditions_Demo  Demonstrates use of 
%PAL_PFHB_fitModel.m to fit multiple psychometric functions to data derived 
%from a single subject testing in multiple conditions using a Bayesian 
%criterion. The model that is fitted is shown here:
%www.palamedestoolbox.org/hierarchicalbayesian.html)
%JAGS (http://mcmc-jags.sourceforge.net/) or cmdSTAN ('command Stan')
%(https://mc-stan.org/users/interfaces/cmdstan.html) must first be
%installed before this will work. JAGS or Stan will perform the MCMC
%sampling of the posterior. Some of the optional tweaks are demonstrated
%here.
%Note that in order for MCMC sampling to converge you'll need at least one
%of these conditions to exist:
%1. High number of trials
%2. Informative priors (default priors are not informative)
%3. High number of participants
%4. Low number of free parameters
%5. Luck
%
%NP (May 2019)

clear all;

engine = input('Use Stan or JAGS (either must be installed from third party first, see PAL_PFHB_fitModel for information)? Type stan or jags: ','s');

x = [-4:1:4];
n = 100*ones(size(x));

data.x = [];
data.y = [];
data.n = [];
data.c = [];

for condition = 1:3
    data.x = [data.x x];
    data.y = [data.y PAL_PF_SimulateObserverParametric([0 1 .02 .02],x,n,@PAL_Logistic)];
    data.n = [data.n n];
    data.c = [data.c condition*ones(size(n))];
end

data.x = [-4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4];
data.y = [4 5 11 27 45 79 86 91 97 7 2 19 28 39 66 93 94 98 3 2 14 29 50 75 91 91 98];
data.n = 100*ones(size(data.x));
data.c = [1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3] ;


pfhb = PAL_PFHB_fitModel(data,'gammaEQlambda',true,'engine',engine,'nsamples',10000);
PAL_PFHB_inspectFit(pfhb,'condition',2);
%The following generates warning and explanation. Included here to stress
%that constraining the lapse rate across conditions is the default.
msg = ['The code that generates the following warning is intentionally included to draw attention to the fact that',char(10),'constraining the lapse rate across conditions is the default:'];
disp(msg);
PAL_PFHB_inspectParam(pfhb,'l','condition',2);
%The following shows diagnostics and derives summary statistics for the 
%difference between the location parameters (aka 'threshold') in conditions 
%1 and 2. Also shows scatter plot between these two parameters.
PAL_PFHB_inspectParam(pfhb,'a','condition',1,'a','condition',2);
%The following shows diagnostics and derives summary statistics for the 
%difference between the location parameters (aka 'threshold') in conditions 
%1 and 2. Also shows scatter plot between the two parameters.
PAL_PFHB_inspectParam(pfhb,'a','condition',1,'l','condition',1);

%The following should lead to (essentially) identical fits, but samples
%from posterior of reparameterized location parameters.

M = [1 1 1; -2 1 1; 0 -1 1]   %Reparameterizes location parameters. E.g., pfhb.summStats.a.mean(1) 
                    %will contain the mean of posterior on the sum of location parameters, 
                    %pfhb.summStats.a.mean(2) will contain the mean of the posterior on 
                    %the difference between location parameters.
                    %pfhb.summStats.a_actual.mean(1) will contain the mean
                    %of the posterior of the location parameter in
                    %condition 1. This posterior was not directly sampled
                    %but rather derived from reparameterized parameters.


pfhb = PAL_PFHB_fitModel(data,'gammaEQlambda',true,'engine',engine,'a',M,'nsamples',10000);
PAL_PFHB_inspectFit(pfhb,'condition',2);
PAL_PFHB_drawViolins(pfhb)
%The following forces the location parameters to be equal across the six
%conditions.
pfhb = PAL_PFHB_fitModel(data,'gammaEQlambda',true,'engine',engine,'a','constrained','nsamples',10000);
