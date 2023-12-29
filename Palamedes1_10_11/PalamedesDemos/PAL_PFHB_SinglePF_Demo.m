%
%PAL_PFHB_SinglePF_Demo  Demonstrates use of PAL_PFHB_fitModel.m to fit a
%single psychometric function to some data using a Bayesian criterion. The 
%model that is fitted is shown here:
%www.palamedestoolbox.org/hierarchicalbayesian.html)
%JAGS (http://mcmc-jags.sourceforge.net/) or cmdSTAN ('command Stan')
%(https://mc-stan.org/users/interfaces/cmdstan.html) must first be
%installed before this will work. JAGS or Stan will perform the MCMC
%sampling of the posterior.
%Note that in order for MCMC sampling to converge you'll need at least one
%of these conditions to exist:
%1. High number of trials (this is why this fit will likely converge)
%2. Informative priors (default priors are not informative)
%3. High number of participants
%4. Low number of free parameters
%5. Luck
%
%NP (May 2019)

clear all;

engine = input('Use Stan or JAGS (either must be installed from third party first, see PAL_PFHB_fitModel for information)? Type stan or jags: ','s');


data.x = [-0.6547 -0.1406 0.3736 0.8878 1.4019 1.9161 2.4303 2.9444 6.9068];
data.y = [3 34 30 33 9 6 2 15 65];
data.n = [6 56 39 37 12 7 3 15 65];

%Use defaults (except for engine):
pfhb = PAL_PFHB_fitModel(data,'engine',engine);      %accepts optional arguments

PAL_PFHB_inspectFit(pfhb);       %accepts optional arguments
PAL_PFHB_inspectParam(pfhb);     %accepts optional arguments
PAL_PFHB_drawViolins(pfhb);      %accepts optional arguments