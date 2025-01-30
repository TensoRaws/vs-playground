ARG BASE_CONTAINER_TAG=cuda

FROM lychee0/vs-pytorch:${BASE_CONTAINER_TAG}

WORKDIR /video

# Install Jupyter
RUN pip install jupyterlab==4.3.4

# Install yuuno
RUN pip install yuuno==1.4

# Install ssh
RUN apt install openssh-server -y && \
    echo 'root:123456' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV JUPYTER_TOKEN=114514
ENV JUPYTER_PORT=8888

EXPOSE $JUPYTER_PORT

EXPOSE 22

CMD service ssh restart ; jupyter lab --ip="*" --port=$JUPYTER_PORT --allow_origin="*" --no-browser --allow-root --ServerApp.token=$JUPYTER_TOKEN --FileContentsManager.delete_to_trash=False
