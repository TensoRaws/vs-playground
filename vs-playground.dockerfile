ARG BASE_CONTAINER_TAG=cuda

FROM lychee0/vs-pytorch:${BASE_CONTAINER_TAG}

# prepare environment
RUN apt update -y && apt upgrade -y

WORKDIR /video

# Install Jupyter
RUN pip install jupyterlab==4.0.0

# Install yuuno
RUN pip install yuuno==1.4

# Install ssh
RUN apt install openssh-server -y
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV JUPYTER_TOKEN=114514
ENV JUPYTER_PORT=8888

EXPOSE $JUPYTER_PORT

EXPOSE 22

CMD service ssh restart ; jupyter lab --ip="*" --port=$JUPYTER_PORT --allow_origin="*" --no-browser --allow-root --ServerApp.token=$JUPYTER_TOKEN
