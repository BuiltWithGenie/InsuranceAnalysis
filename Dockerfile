FROM julia:latest

RUN apt-get update && apt-get install -y vim

RUN useradd --create-home --shell /bin/bash genie
RUN mkdir /home/genie/app
COPY . /home/genie/app
WORKDIR /home/genie/app

RUN chown -R genie:genie /home/genie && \
    chmod -R 755 /home/genie/app
RUN mkdir -p /home/genie/app/log && \
    chown -R genie:genie /home/genie/app/log && \
    chmod -R 755 /home/genie/app/log

USER genie

RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); "

EXPOSE 8000
EXPOSE 80

ENV JULIA_DEPOT_PATH "/home/genie/.julia"
ENV JULIA_REVISE "off"
ENV GENIE_ENV "prod"
ENV GENIE_HOST "0.0.0.0"
ENV PORT "8000"
ENV WSPORT "8000"
ENV EARLYBIND "true"

# Create a shell script to check for sysimage and run appropriate command
RUN echo '#!/bin/bash\n\
if [ -f /data/arkdemo.so ]; then\n\
    exec julia --sysimage=/data/arkdemo.so -e "using GenieFramework;Genie.loadapp();up()" --project\n\
else\n\
    exec julia --project -e "using GenieFramework; Genie.loadapp(); up(async=false);"\n\
fi' > /home/genie/entrypoint.sh && chmod +x /home/genie/entrypoint.sh

ENTRYPOINT ["/home/genie/entrypoint.sh"]
