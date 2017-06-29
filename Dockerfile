FROM ubuntu:xenial

ADD entrypoint /entrypoint

# Create working guix system under ubuntu
RUN apt-get update \
 && apt-get install -y wget xz-utils \
 \
 && cd /tmp \
 && wget https://alpha.gnu.org/gnu/guix/guix-binary-0.13.0.x86_64-linux.tar.xz \
 && wget https://alpha.gnu.org/gnu/guix/guix-binary-0.13.0.x86_64-linux.tar.xz.sig \
 && gpg --keyserver pgp.mit.edu --recv-keys 3CE464558A84FDC69DB40CFB090B11993D9AEBB5 \
 && gpg --verify guix-binary-0.13.0.x86_64-linux.tar.xz.sig \
 \
 && mkdir guix-unpack && cd guix-unpack \
 && tar --warning=no-timestamp -xf ../guix-binary-0.13.0.x86_64-linux.tar.xz \
 && mv var/guix /var/ && mv gnu / \
 && ln -sf /var/guix/profiles/per-user/root/guix-profile ~root/.guix-profile \
 \
 && groupadd --system guixbuild \
 && for i in `seq -w 1 10`; do \
      useradd -g guixbuild -G guixbuild \
              -d /var/empty -s `which nologin` \
              -c "Guix build user $i" --system \
                 guixbuilder$i; \
    done \
 \
 && ln -s /var/guix/profiles/per-user/root/guix-profile/bin/guix /usr/local/bin/guix \
 && guix archive --authorize < ~root/.guix-profile/share/guix/hydra.gnu.org.pub \
 \
 && echo 'guix-daemon --build-users-group=guixbuild' >> /usr/local/bin/start-guix && chmod +x /usr/local/bin/start-guix \
 && chmod +x /entrypoint \
 \
 && apt-get remove -y wget xz-utils && rm -Rf /tmp/guix-*

CMD ["/entrypoint"]
