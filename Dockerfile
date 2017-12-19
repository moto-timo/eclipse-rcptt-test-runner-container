# Copyright (C) 2015-2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

FROM crops/yocto:ubuntu-16.04-base

USER root

ADD https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_useradd.sh  \
        https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_groupadd.sh \
        https://raw.githubusercontent.com/crops/extsdk-container/master/usersetup.py \
        /usr/bin/
COPY rcptt-test-runner-entry.py rcptt-test-runner-launch.sh /usr/bin/
COPY sudoers.usersetup /etc/
ADD http://download.eclipse.org/rcptt/release/2.2.0/runner/rcptt.runner-2.2.0.zip /tmp/
ADD http://download.eclipse.org/technology/epp/downloads/release/oxygen/R/eclipse-cpp-oxygen-R-linux-gtk-x86_64.tar.gz /tmp/
#COPY rcptt.runner-2.1.0.zip eclipse-cpp-neon-R-linux-gtk-x86_64.tar.gz /tmp/
COPY default-rcptt-project/ /usr/share/rcptt/project

# We remove the user because we add a new one of our own.
# The usersetup user is solely for adding a new user that has the same uid,
# as the workspace. 70 is an arbitrary *low* unused uid on debian.
RUN apt-get -y update && \
    apt-get -y install sudo openjdk-8-jdk && \
    apt-get clean && \
    mkdir -p /etc/skel/.vnc && \
    echo "" | vncpasswd -f > /etc/skel/.vnc/passwd && \
    chmod 0600 /etc/skel/.vnc/passwd && \
    /usr/sbin/locale-gen en_US.UTF-8 && \
    userdel -r yoctouser && \
    groupadd -g 70 usersetup && \
    useradd -N -m -u 70 -g 70 usersetup && \
    chmod 755 /usr/bin/usersetup.py \
        /usr/bin/rcptt-test-runner-entry.py \
        /usr/bin/rcptt-test-runner-launch.sh \
        /usr/bin/restrict_groupadd.sh \
        /usr/bin/restrict_useradd.sh && \
    chmod 644 /tmp/rcptt.runner*.zip \
        /tmp/eclipse-cpp*.tar.gz && \
    echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

USER usersetup
ENV LANG=en_US.UTF-8

ENTRYPOINT ["rcptt-test-runner-entry.py"]
