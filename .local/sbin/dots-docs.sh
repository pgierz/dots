#!/bin/bash -e
old_notebook=$(nb notebooks current)
nb use pauls_dotfile_guide
nb $*
nb use ${old_notebook}
