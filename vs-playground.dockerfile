FROM lychee0/vs-pytorch:dev

WORKDIR /video

# Install Jupyter
RUN conda install conda-forge::jupyterlab=4.0.0 -y

# Install yuuno
RUN pip install yuuno==1.4

ENV JUPYTER_TOKEN=homo
ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT
CMD jupyter lab --ip="*" --port=$JUPYTER_PORT --allow_origin="*" --no-browser --allow-root --ServerApp.token=$JUPYTER_TOKEN
