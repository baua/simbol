FROM       ubuntu:14.04
MAINTAINER Nima Talebi "docker@nima.id.au"
ENV        VERSION 0.6
ENV        DEBIAN_FRONTEND noninteractive
EXPOSE     22

RUN [ "apt-get", "update", "-q", "-q" ]
RUN [ "apt-get", "dist-upgrade", "-q", "-q", "--yes" ]
RUN [ "apt-get", "install", "-q", "-q", "--yes",        \
    "libbz2-dev", "libreadline-gplv2-dev", "libssl-dev" \
]

RUN [ "apt-get", "install", "-q", "-q", "--yes", \
    "coreutils", "gcc", "make",                  \
    "bash", "sed", "gawk",                       \
    "git", "haveged",                            \
    "wget", "curl",                              \
    "ssh"                                        \
]

RUN [ "mkdir", "-p", "/opt/schtunt" ]
RUN [ "git", "clone", "https://github.com/baua/simbol.git", "/opt/schtunt/simbol" ]
WORKDIR /opt/schtunt/simbol
RUN [ "git", "checkout", "develop" ]

ENTRYPOINT [ "/root/bin/simbol" ]

# vim:syntax=ruby
