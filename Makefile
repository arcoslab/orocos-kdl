PREFIX ?= ${HOME}/local/DIR/kdl

built: patched
	mkdir -p kdl/orocos_kdl/build
	cd kdl/orocos_kdl/build && cmake -D CMAKE_INSTALL_PREFIX:PATH=$(PREFIX) ..
	cd kdl/orocos_kdl/build && make clean && make -j5
	touch built

patched:
	git clone https://github.com/orocos/orocos_kinematics_dynamics.git kdl
	cd kdl; git checkout 8e45049;  cd ..;
	cat *.patch | patch -d kdl -p1
	cd ..
	touch patched

uninstall: uninstall-python
	-cd ${PREFIX}/../ && xstow -D `basename ${PREFIX}` && rm -rf `basename ${PREFIX}`

install: built uninstall
	cd kdl/orocos_kdl/build && make install
	cd ${PREFIX}/../ && xstow `basename ${PREFIX}`

built-python: install
	mkdir -p kdl/python_orocos_kdl/build
	cd kdl/python_orocos_kdl/build && cmake -D CMAKE_INSTALL_PREFIX:PATH=$(PREFIX)-python ..
	cd kdl/python_orocos_kdl/build && make clean && make -j5

uninstall-python:
	-cd ${PREFIX}/../  && xstow -D `basename ${PREFIX}`-python && rm -rf `basename ${PREFIX}`-python


install-python: uninstall-python built-python
	cd kdl/python_orocos_kdl/build && make install
	cd ${PREFIX}/../ && xstow `basename ${PREFIX}`-python

sysdep:
	apt-get install sip4 python-sip4 python-sip4-dev

clean:
	rm -rf kdl patched built
