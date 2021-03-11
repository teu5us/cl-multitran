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

(defun ask-multitran (term &optional beg end)
  (interactive (cond
                ((use-region-p)
                 (list nil (region-beginning) (region-end)))
                ((eql major-mode 'exwm-mode)
                 (list (gui-get-primary-selection) nil nil))
                (t
                 (list nil nil nil))))
  (cl-flet ((rs (str) (string-trim (read-string str)))
            (lang-if-cpa (str lang)
                         (if (and cpa
                                  (or (= cpa 4)
                                      (> cpa 16)))
                             (rs str)
                           lang)))
    (let* ((cpa (unless (null current-prefix-arg)
                  (car current-prefix-arg)))
           (word (cond
                  (term term)
                  ((and beg end)
                   (buffer-substring-no-properties beg end))
                  (t
                   (or (current-word t t) (rs "Word to translate: ")))))
           (from (lang-if-cpa "Translate from: " multitran-from))
           (to (lang-if-cpa "Translate to: " multitran-to)))
      (with-help-window "*Multitran*"
        (princ (shell-command-to-string
                (format "mtran -w \"%s\" -f %s -t %s %s"
                        word from to
                        (if (and cpa (>= cpa 16)) "-p" "")))))
      (with-current-buffer "*Multitran*"
        (org-mode)
        (when (and cpa (>= cpa 16))
          (+org/close-all-folds))))))

(set-popup-rule! "^\\*Multitran" :slot -1 :size 0.3 :select t)

(global-set-key (kbd "s-m") #'ask-multitran)
(exwm-input-set-key (kbd "s-y") #'ask-multitran)
```

## License

MIT
