#!/bin/bash

if [[ "$ASAN" == "yes" ]]; then
    export ASAN_OPT="--enable-asan"
fi

#disable buggy formats. If a formats fails its tests on super, I will burn it.
cd src
./buggy.sh disable
cd -

if [[ "$TEST" == "usual" ]]; then
    cd src

    # Build and run with the address sanitizer instrumented code
    export ASAN_OPTIONS=symbolize=1
    export ASAN_SYMBOLIZER_PATH=$(which llvm-symbolizer)

    # Prepare environment
    sudo apt-get update -qq
    sudo apt-get install libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev
    sudo apt-get install fglrx-dev opencl-headers || true

    # Configure and build
    ./configure $ASAN_OPT $BUILD_OPTS
    make -sj4

    ../.travis/tests.sh

elif [[ "$TEST" == "fresh" ]]; then
    # ASAN using a 'recent' enrironment (compiler/OS)
    docker run -v $HOME:/root -v $(pwd):/cwd ubuntu:17.04 sh -c " \
      cd /cwd/src; \
      apt-get update -qq; \
      apt-get install -y build-essential libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev libbz2-dev wget; \
      ./configure $ASAN_OPT $BUILD_OPTS; \
      make -sj4; \
      export OPENCL="""$OPENCL"""; \
      PROBLEM='slow' EXTRAS='yes' ../.travis/tests.sh
   "

elif [[ "$TEST" == "TS --restore" ]]; then
    # Test Suite --restore run
    cd src

    # Prepare environment
    sudo apt-get update -qq
    sudo apt-get install libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev

    # Configure and build
    ./configure
    make -sj4

    cd ..
    git clone --depth 1 https://github.com/magnumripper/jtrTestSuite.git tests
    cd tests
    #export PERL_MM_USE_DEFAULT=1
    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan
    cpan install Digest::MD5
    ./jtrts.pl --restore

elif [[ "$TEST" == "TS" ]]; then
    # Test Suite run
    cd src

    # Prepare environment
    sudo apt-get update -qq
    sudo apt-get install libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev
    sudo apt-get install fglrx-dev opencl-headers || true

    # Configure and build
    ./configure
    make -sj4

    cd ..
    git clone --depth 1 https://github.com/magnumripper/jtrTestSuite.git tests
    cd tests
    #export PERL_MM_USE_DEFAULT=1
    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan
    cpan install Digest::MD5

    if [[ "$OPENCL" != "yes" ]]; then
        ./jtrts.pl -stoponerror -dynamic none
    else
        # Disable failing formats
        echo 'descrypt-opencl = Y' >> john-local.conf

        ./jtrts.pl -noprelims -type opencl
    fi

elif [[ "$TEST" == "TS --internal" ]]; then
    # Test Suite run
    cd src

    # Prepare environment
    sudo apt-get update -qq
    sudo apt-get install libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev
    sudo apt-get install fglrx-dev opencl-headers || true

    # Configure and build
    ./configure
    make -sj4

    cd ..
    git clone --depth 1 https://github.com/magnumripper/jtrTestSuite.git tests
    cd tests
    #export PERL_MM_USE_DEFAULT=1
    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan
    cpan install Digest::MD5

    ./jtrts.pl -noprelims -internal

elif [[ "$TEST" == "TS docker" ]]; then
    # Test Suite run
    docker run -v $HOME:/root -v $(pwd):/cwd ubuntu:xenial sh -c ' \
      cd /cwd/src; \
      apt-get update -qq; \
      apt-get install -y build-essential libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev libbz2-dev git; \
      ./configure; \
      make -sj4; \
      cd ..; \
      git clone --depth 1 https://github.com/magnumripper/jtrTestSuite.git tests; \
      cd tests; \
      cpan install Digest::MD5; \
      ./jtrts.pl --restore
    '
else
    echo
    echo  -----------------
    echo  "Nothing to do!!"
    echo  -----------------
fi
