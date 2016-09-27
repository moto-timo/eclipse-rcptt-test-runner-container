Eclipse RCPTT Test Runner Container
========================
This repo is to create an image that is able to run RCPTT tests. The main
difference between it and https://github.com/crops/yocto-dockerfiles is that
it has helpers to create users and groups within the container. This is so that
the output generated in the container will be readable by the user on the
host.

TL;DR
docker run --rm -t -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 -e DISPLAY=:0 -v /home/<user>/workdir:/workdir crops/eclipse-rcptt-test-runner:neon-debug

Brief Introduction to RCPTT
---------------------------
RCPTT (Rich Client Platform Testing Tool) was originally a commercial product called Q7, which was open sourced by Xored. While it is most commonly used for testing Eclipse, it is actually designed to test any OSGI (Open Source Gateway Initiative) compliant application, which all Eclipse applications and plugins are. It provides an IDE to develop tests, plugins that can be installed in the developer's IDE, and headless test runners for Linux, Windows and Mac OS X which can be used for continuous integration. It provides examples for calling the test runner from a shell script, Maven, Ant or the command line. Like most testing frameworks, it has test suites which consist of test cases. Unlike most testing frameworks, it uses pickled java objects to: (1) represent a starting state of the UI, known as a Context; (2) represent the expected final state of an object (such as a GUI widget), known as a Validation. These binary blobs are created graphically using the RCPTT IDE. A test case might consist of set-up (setting a Context), several UI interactions run from a script, verifying the results by comparing to a Validation, and a tear-down.

Running the container
---------------------
Here a very simple but usable scenario for using the container is described.
It is by no means the *only* way to run the container, but is a great starting
point.

* **Create a workdir**

  First we'll create a directory that will be used as the RCPTT workspace
  and as the location of the RCPTT project (the tests to be run). The test
  results will be in this same workspace.

  ```
  mkdir /home/myuser/workdir
  ```

  For the rest of the instructions we'll assume the workdir chosen was
  `/home/myuser/workdir`.

* **The docker command**

  Assuming you used the *workdir* from above, the command
  to run a container for the first time would be:

  ```
  docker run --rm -it -v /home/myuser/hostworkdir:/workdir crops/rcptt \
  --workdir=/workdir --project=relative/path/to/project \
  ```

  Let's discuss some of the options:
  * **_-v /home/myuser/workdir:/workdir**: The default location of the
    workspace inside of the container is /workdir. So this part of the
    command says to use */home/myuser/workdir* as */workdir* inside the
    container.
  * **_--workdir=/workdir**: This causes the container to start in the
    workspace specified. In this case it corresponds to */home/myuser/hostworkdir* due to
    the previous *-v* argument. The container will also use the uid and gid
    of the workdir as the uid and gid of the user in the container.
  * **_--test-project=relative/path/to/some/rcptt/project_**: This causes the
    project directory specified to be used for the RCPTT project (the source
    of the tests), rather than the default project bundled inside the container.


  This debug version of the container will first launch ```xeyes``` to make
  sure that your X11 display is working properly. Once you exit ```xeyes```,
  the launcher will copy the RCPTT project to */workdir/temp-project*. It will
  delete the *temp-project* folder if it is already present in the *workdir*.
  The RCPTT test runner itself will then delete and re-create the
  */workdir/results* directory. The tests found in the RCPTT project will be
  automatically run and all output will go into the *results* directory.

  /* TODO */
  QEMU and SDK Set-up
  -------------------
  Because this container is designed to run tests on the Yocto Project Eclipse
  Plugin, we need a few more items. The tests will interact with a QEMU image
  and rootfs, as well as an SDK. Three more command line options are therefore
  required to run the default test suite:

  * **_--kernel-image=file://valid/path/to/bzImage_qemux86.bin_**: This tells
  the container where to find the kernel image that will be used to emulate the
  target platform.
  * **_--target-rootfs=file://valid/URI/to/extracted/rootfs_**: This tells the
  container where to find the **rootfs** that will be used by QEMU. Note that
  this **_MUST_** be extraced by the ```runqemu-extract-sdk```, because it
  needs to have the ```pseudo...FIXME``` directory which sets permissions on
  the host to allow it to interact with the target rootfs.
  * **_--toolchain-root=file://valid/path/to/toolchain_**: This tells the
  container where to find the compiler and other tools that will be used
  to cross-compile your application for the QEMU target. This SDK **_MUST_**
  have been generated with the proper additional tools for Eclipse support.

  Running Against Locally Built Image
  -----------------------------------
  Above we assumed a downloaded pre-built scenario, if instead you are building
  locally, the options are slightly different:

  * **_--kernel-image=file:///tmp/deploy/images/qemux86/bzImage-qemux86.bin_**:
  This tells the container to use the image built built locally.
  * **_--target-rootfs=

  Future work
  -----------
  Ideally, a base container which did not assume QEMU usage would be created
  with a container that inherits from it and targets QEMU and another container
  which targets hardware. This adds complexity that is currently undesireable.
