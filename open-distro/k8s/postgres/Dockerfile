FROM python:alpine
RUN apk --no-cache add postgresql

FROM python:alpine
RUN apk --no-cache add moreutils
COPY --from=0 /usr/bin/pg_dump /usr/bin/pg_restore /usr/bin/pg_dumpall /usr/bin/pg_isready /usr/bin/
COPY --from=0 /usr/lib/libpq.so.5 /usr/lib/libldap_r-2.4.so.2 /usr/lib/liblber-2.4.so.2 /usr/lib/libsasl2.so.3 /usr/lib/
COPY --from=0 /lib/ld-musl-x86_64.so.1 /lib/libz.so.1 /lib/ld-musl-x86_64.so.1 /lib/libssl.so.1.1 /lib/libcrypto.so.1.1 /lib/

RUN addgroup user &&\
    adduser -D -G user user

USER user

WORKDIR /home/user
ENV PATH /usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/.local/bin:/home/user
COPY --chown=user entrypoint.py requirements.txt dumpDatabase.sh restoreDatabase.sh ./
# Install awscli
RUN chmod +x /home/user/*.sh && pip install -r ./requirements.txt --upgrade --user

# ENTRYPOINT ["python", "-u", "entrypoint.py"]
CMD ["python", "-u", "entrypoint.py"]
