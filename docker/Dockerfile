
# Tsugi PG4E Test harness

FROM tsugi_dev:latest

COPY tsugi-pg4e-prepare.sh /usr/local/bin
COPY tsugi-pg4e-startup.sh /usr/local/bin
COPY charles-server-start.sh /usr/local/bin/charles-server-start.sh

# Install.
RUN bash /usr/local/bin/tsugi-pg4e-prepare.sh

#  apt-get install -y mailutils

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

EXPOSE 80 443 3306
ENTRYPOINT ["bash", "/usr/local/bin/tsugi-pg4e-startup.sh"]

# Define default command.
CMD ["bash"]
