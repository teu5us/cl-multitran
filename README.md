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

### Example use with Doom Emacs

```emacs-lisp
(defvar multitran-from "en")
(defvar multitran-to "ru")

(defun ask-multitran (beg end)
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list nil nil)))
  (labels ((rs (str) (string-trim (read-string str)))
           (lang-if-cpa (str lang)
                        (if (and cpa
                                 (or (= cpa 4)
                                     (> cpa 16)))
                            (rs str)
                          lang)))
    (let* ((cpa (unless (null current-prefix-arg)
                  (car current-prefix-arg)))
           (word (if (and beg end)
                     (buffer-substring-no-properties beg end)
                   (or (current-word nil t) (rs "Word to translate: "))))
           (from (lang-if-cpa "Translate from: " multitran-from))
           (to (lang-if-cpa "Translate to: " multitran-to)))
      (with-help-window "*Multitran*"
        (princ (shell-command-to-string
                (format "mtran -w \"%s\" -f %s -t %s %s"
                        word from to
                        (if (and cpa (>= cpa 16)) "-p" "")))))
      (with-current-buffer "*Multitran*"
        (org-mode)
        (evil-define-key 'normal (current-local-map) (kbd "q") #'kill-this-buffer)))))

(set-popup-rule! "^\\*Multitran" :slot -1 :size 0.3 :select t)

(global-set-key (kbd "s-m") #'ask-multitran)
```

## License

MIT
