
# https://github.com/ourownstory/neural_prophet
# conda activate /Users/jbg/Library/r-miniconda
# pip install neuralprophet
library(reticulate)
reticulate::repl_python()

from neuralprophet import NeuralProphet
m = NeuralProphet()

# TODO: create dataframe


metrics = m.fit(df, freq="D")
forecast = m.predict(df)
# You can visualize your results with the inbuilt plotting functions:
  
fig_forecast = m.plot(forecast)
fig_components = m.plot_components(forecast)
fig_model = m.plot_parameters()
# If you want to forecast into the unknown future, extend the dataframe before predicting:
  
m = NeuralProphet().fit(df, freq="D")
df_future = m.make_future_dataframe(df, periods=30)
forecast = m.predict(df_future)
fig_forecast = m.plot(forecast)
