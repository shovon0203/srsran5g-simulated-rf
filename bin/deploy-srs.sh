set -ex
COMMIT_HASH=$1
SRS_TYPE=$2
BINDIR=`dirname $0`
SRCDIR=/var/tmp
CFGDIR=/local/repository/etc
SRS_REPO=https://github.com/shovon0203/srsRAN_Project

if [ -f $SRCDIR/$SRS_TYPE-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

install_srsran_common () {
    sudo apt update
    sudo apt install -y \
        cmake \
        libfftw3-dev \
        libmbedtls-dev \
        libsctp-dev \
        libzmq3-dev
}

clone_build_install () {
    cd $SRCDIR
    git clone $SRS_REPO
    cd $SRS_TYPE
    git checkout $COMMIT_HASH
    mkdir build
    cd build
    if [ "$SRS_TYPE" = "srsRAN_Project" ]; then
        cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON
    else
        cmake ../
    fi
    make -j `nproc`
    sudo make install
    sudo ldconfig
}

install_srsran_4g () {
    install_srsran_common
    sudo apt install -y \
        build-essential \
        libboost-program-options-dev \
        libconfig++-dev \

    clone_build_install
    sudo srsran_install_configs.sh service
    sudo cp /local/repository/etc/srsran/* /etc/srsran/
}

install_srsran_project () {
    install_srsran_common
    sudo apt install -y \
        make \
        gcc \
        g++ \
        pkg-config \
        libyaml-cpp-dev \
        libgtest-dev

    clone_build_install
}

install_srsran_gui () {
    sudo apt update
    sudo apt install -y \
        libboost-system-dev \
        libboost-test-dev \
        libboost-thread-dev \
        libqwt-qt5-dev \
        qtbase5-dev

    clone_build_install
}

if [ "$SRS_TYPE" = "srsRAN_4G" ]; then
    install_srsran_4g
elif [ "$SRS_TYPE" = "srsRAN_Project" ]; then
    install_srsran_project
elif [ "$SRS_TYPE" = "srsGUI" ]; then
    install_srsran_gui
else
    echo "unknown SRS_TYPE: $SRS_TYPE"
    exit 1
fi

touch $SRCDIR/$SRS_TYPE-setup-complete
