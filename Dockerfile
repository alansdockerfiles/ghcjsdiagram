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

RUN git clone https://github.com/ghcjs/ghcjs.git                                                                                                                                                                   
RUN git clone https://github.com/ghcjs/ghcjs-prim.git && \                                                                                                                                                         
    cabal install --reorder-goals --max-backjumps=-1 ./ghcjs ./ghcjs-prim                                                                                                                                          
ENV PATH /root/.cabal/bin:$PATH                                                                                                                                                                                    
RUN ln -s /usr/bin/nodejs /usr/bin/node                                                                                                                                                                            
RUN ghcjs-boot --dev                                                                                                                                                                                               
WORKDIR /root                                                                                                                                                                                                      
RUN git clone https://github.com/ghcjs/diagrams-ghcjs.git                                                                                                                                                          
WORKDIR /root/diagrams-ghcjs                                                                                                                                                                                       
RUN cabal install --ghcjs                                                                                                                                                                                          
WORKDIR /root                                                                                                                                                                                                      
#RUN git clone https://github.com/ghcjs/ghcjs-canvas.git && cd ghcjs-canvas && cabal install --ghcjs                                                                                                               
#RUN git clone https://github.com/ghcjs/ghcjs-jquery.git && cd ghcjs-jquery && cabal install --ghcjs   
