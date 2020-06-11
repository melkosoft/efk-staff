FROM python:alpine
MAINTAINER Mike Petersen <mike@odania-it.de>

RUN apk --no-cache add postgresql

RUN adduser -S user
USER user
WORKDIR /home/user
ENV PATH /usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/.local/bin

# Install awscli
RUN pip install awscli --upgrade --user

COPY dumpDatabase.sh .
COPY restoreDatabase.sh .

ENTRYPOINT [ "/bin/sh" ]
CMD [ "./dumpDatabase.sh" ]