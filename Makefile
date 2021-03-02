LISP ?= ros run --

.PHONY: all

all:
	@$(LISP) --eval "(ql:quickload :cl-multitran)" \
		--eval "(asdf:make :cl-multitran)"
