#!/usr/bin/env python

# rcptt-test-runner-entry.py
#
# This script is to present arguments to the user of the container and then
# chuck them over to the scripts that actually do the work.
#
# Copyright (C) 2016 Intel Corporation
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
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument('--workdir', default='/workdir',
                    help='The active directory once the container is running. '
                         'In the abscence of the "id" argument, the uid and '
                         'gid of the workdir will also be used for the user '
                         'in the container.')
parser.add_argument("--id",
                    help='uid and gid to use for the user inside the '
                         'container. It should be in the form uid:gid')
parser.add_argument('--project', default='/workdir/project',
		    help='The RCPTT project once the container is running. '
			 'This is where the tests themselves are defined. ')
parser.add_argument('--args', nargs=argparse.REMAINDER,
                    help='Any remaining arguments are passed to the test runner. '
                         'Examples:'
                         '  -injection:/path/to/directory/containing/plugins '
                         '  -autVMArgs -Dsomeproperty=somevalue ' )

args = parser.parse_args()


idargs = ""
if args.id:
    uid, gid = args.id.split(":") 
    idargs = "--uid={} --gid={}".format(uid, gid)

rcpttargs = ""
if args.args:
    for arg in args.args:
        rcpttargs += arg if rcpttargs==None else ' '.join(arg)

cmd = """usersetup.py --username=rcpttuser --workdir={wd} {idargs}
         rcptt-test-runner-launch.sh {wd} {prj} {rcpttargs}""".format(wd=args.workdir, idargs=idargs, prj=args.project, rcpttargs=rcpttargs )
cmd = cmd.split()
os.execvp(cmd[0], cmd)
#print cmd
