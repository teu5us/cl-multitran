LISP ?= ros run --

.PHONY: all

all:
	@$(LISP) --eval "(ql:quickload :cl-multitran)" \
		--eval "(declaim (optimize (speed 3) (debug 0) (safety 0) (space 0) (compilation-speed 0)))" \
		--eval "(asdf:make :cl-multitran)"
