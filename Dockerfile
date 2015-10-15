FROM debian:unstable                                                                                                                                                                                        
RUN echo deb http://httpredir.debian.org/debian experimental main >> /etc/apt/sources.list                                                                                                                  
RUN apt-get update                                                                                                                                                                                          
RUN apt-get install -y --no-install-recommends -t experimental ghc                                                                                                                                          
RUN apt-get install -y --no-install-recommends -t experimental cabal-install alex happy                                                                                                                     
RUN apt-get install -y zlib1g-dev                                                                                                                                                                           
RUN apt-get install -y build-essential git libtinfo-dev libgmp-dev autoconf curl                                                                                                                            
RUN cabal update && \                                                                                                                                                                                       
    cabal install cabal-install Cabal                                                                                                                                                                       
                                                                                                                                                                                                            
RUN curl -sL https://deb.nodesource.com/setup | bash - \                                                                                                                                                    
    && apt-get install -y nodejs                                                                                                                                                                            
RUN echo 2
RUN git clone https://github.com/ghcjs/ghcjs.git
RUN cabal install --reorder-goals --max-backjumps=-1 ./ghcjs
ENV PATH /root/.cabal/bin:$PATH
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN ghcjs-boot --dev
WORKDIR /root
RUN apt-get install -y vim
RUN git clone https://github.com/xpika/ghcjs-dom.git && cd ghcjs-dom && cabal install --ghcjs
RUN git clone https://github.com/ghcjs/ghcjs-jquery.git && cd ghcjs-jquery && cabal install --ghcjs
RUN git clone https://github.com/ghcjs/diagrams-ghcjs.git && cd diagrams-ghcjs && cabal install --ghcjs
WORKDIR /root/diagrams-ghcjs/
RUN git remote add my https://github.com/xpika/diagrams-ghcjs.git
RUN git pull my master
WORKDIR /root/diagrams-ghcjs/test
RUN make
WORKDIR /root/
RUN cabal install snap-server
RUN echo 'ghc -e "Snap.Http.Server.httpServe (Snap.Http.Server.Config.setPort 80 mempty) $ Snap.Util.FileServe.serveDirectoryWith Snap.Util.FileServe.fancyDirectoryConfig  \".\""' > server.sh
ENTRYPOINT ["sh","-c","cd /root/diagrams-ghcjs/test; sh -c 'sh /root/server.sh > /root/log 2>&1 &' ; /bin/bash"]
