function result = LogRegPredict(data, coefs)
% Calls (linear) logistic regression on the observation.
% @param data - k-length vector represention observation
% @param coefs - coefficients for logistic regression, should have length
% k+1
% @returns result - the prediction of the logistic regression
result = dot([1 data], coefs');
end