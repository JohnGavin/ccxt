library(mlflow)
# vignette(package = 'mlflow')
# https://github.com/mlflow/mlflow
# https://mlflow.org/docs/latest/R-api.html

# https://docs.seldon.io/projects/seldon-core/en/latest/R/README.html
# model in a docker image ready for deployment with Seldon Core


# install MLflow, 
# install_mlflow(python_version = "3.8")
# start the user interface, 
# launch mlflow ui locally
mlflow_ui()

# launch mlflow ui for existing mlflow server
# mlflow_set_tracking_uri("http://tracking-server:5000")
# mlflow_ui()

# create and list experiments, 
# save models, 
# run projects and 
# serve models among many other functions available in the R API.

