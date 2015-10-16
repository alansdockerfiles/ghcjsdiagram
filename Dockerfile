FROM debian:unstable                                                                                                                                                                                        
RUN echo deb http://httpredir.debian.org/debian experimental main >> /etc/apt/sources.list                                                                                                                  
RUN apt-get update                                                                                                                                                                                          
RUN apt-get install -y --no-install-recommends -t experimental ghc cabal-install alex happy
RUN apt-get install -y --no-install-recommends zlib1g-dev  build-essential git ca-certificates libtinfo-dev libgmp-dev autoconf curl nodejs vim
RUN cabal update && cabal install cabal-install Cabal
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN git clone https://github.com/ghcjs/ghcjs.git
RUN cabal install --reorder-goals --max-backjumps=-1 ./ghcjs
ENV PATH /root/.cabal/bin:$PATH
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN ghcjs-boot --dev
WORKDIR /root
RUN git clone https://github.com/xpika/ghcjs-dom.git && cd ghcjs-dom && cabal install --ghcjs
RUN git clone https://github.com/ghcjs/ghcjs-jquery.git && cd ghcjs-jquery && cabal install --ghcjs
RUN git clone https://github.com/xpika/diagrams-ghcjs.git && cd diagrams-ghcjs && cabal install --ghcjs
WORKDIR /root/diagrams-ghcjs/test
RUN make
WORKDIR /root/
RUN cabal install snap-server
RUN echo 'ghc -e "Snap.Http.Server.httpServe (Snap.Http.Server.Config.setPort 80 mempty) $ Snap.Util.FileServe.serveDirectoryWith Snap.Util.FileServe.fancyDirectoryConfig  \".\""' > server.sh
ENTRYPOINT ["sh","-c","cd /root/diagrams-ghcjs/test; sh -c 'sh /root/server.sh > /root/log 2>&1 &' ; /bin/bash"]
