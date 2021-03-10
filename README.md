# cl-multitran

This is a small program to get word translations from multitran.com

## Install

Requires [cl-fill-string](https://github.com/Teu5us/cl-fill-string).

Clone the repository:

```sh
git clone https://github.com/Teu5us/cl-multitran.git
```

`cd` inside:

```sh
cd cl-multitran
```

If you have roswell installed, run `make` or `ros install roswell/mtran.ros`.

Otherwise, if you have a compiler (e.g. sbcl) and quicklisp, run `make LISP=sbcl`.

## Use

```sh
mtran -h

=>
MTRAN [OPTIONS]

  -w --word                       string   What to translate.
  -f --from                       string   Language to translate from.
  -t --to                         string   Language to translate to.
  -p --phrases                    boolean  Load phrases instead of translations.
  -c --col                        string   Fill-column.
  -h --help                       boolean  Show this help.
```

```sh
mtran -w hello -f en -t ru
mtran -w hello -f en -t ru -p
mtran -w hello -f en -t ru -c 80
mtran -w hello -f en -t ru -c 80 -p
```

## License

MIT
