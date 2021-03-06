;;; packages.el --- latex-custom layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Rui Hu <hrfudan@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `latex-custom-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `latex-custom/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `latex-custom/pre-init-PACKAGE' and/or
;;   `latex-custom/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst latex-custom-packages
  '(
    auctex
    (cdlatex :location local)
    )
  "The list of Lisp packages required by the latex-custom layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun latex-custom/post-init-auctex ()
    ;; ; turn on TeX-source-correlate-mode automatically
    ;; (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
    ; turn on interactive
    (add-hook 'LaTeX-mode-hook 'TeX-interactive-mode)
    ; turn on auto-fill-mode
    ;; (add-hook 'LaTeX-mode-hook 'auto-fill-mode)
    ;; Highlight TIP in latex mode
    (add-hook 'LaTeX-mode-hook
              (lambda ()
                (font-lock-add-keywords nil
                                        '(("\\<\\(TIP\\):" 1 font-lock-warning-face t)))
                ))
    ;; (add-hook 'LaTeX-mode-hook 'turn-on-reftex) ;; reftex is needed for cdlatex labels to work
    (add-hook 'LaTeX-mode-hook 'flyspell-mode)   ; with AUCTeX LaTeX mode
    ;; (add-hook 'latex-mode-hook 'flyspell-mode)   ; with Emacs latex mode
    ;; Set the minimum number of characters for completion to be 4
    ;; TIP: config works like eval-after-load, so for buffer-local settings, one should use mode hook
    (add-hook 'LaTeX-mode-hook '(lambda ()
                                  (setq-local company-minimum-prefix-length 4)))
    ;; (add-hook 'reftex-mode-hook '(lambda ()
    ;;                                (define-key reftex-mode-map "j" 'reftex-toc-previous)
    ;;                                (define-key reftex-mode-map "k" 'reftex-toc-next)
    ;;                                ;; k was originally bound to reftex-toc-quit-and-kill, so rebind it 
    ;;                                (define-key reftex-mode-map "n" 'reftex-toc-quit-and-kill)
    ;;                                ;; the following keys will be unset
    ;;                                (define-key reftex-mode-map "C-n" nil)
    ;;                                (define-key reftex-mode-map "C-p" nil)
    ;;                                ))

    (defun setup-synctex-latex ()
      (setq TeX-source-correlate-method (quote synctex))
      (setq TeX-source-correlate-mode t)
      (setq TeX-source-correlate-start-server t)
      ;; (setq TeX-view-program-list
      ;;       (quote
      ;;        (("Okular" "okular --unique \"%o#src:%n$(pwd)/./%b\""))))
      (setq TeX-view-program-selection
            (quote
             (((output-dvi style-pstricks)
               "dvips and gv")
              (output-dvi "xdvi")
              (output-pdf "PDF Tools")
              (output-html "xdg-open")))))


    (add-hook 'LaTeX-mode-hook 'setup-synctex-latex)
    ;; the latexmk option -pvc makes latexmk automatically update pdf whenever changes are made to source file.
    (add-hook 'LaTeX-mode-hook (lambda () (add-to-list 'TeX-command-list '("MkLaTeX" "latexmk -pdf -pdflatex='lualatex -interaction=scrollmode -file-line-error -halt-on-error -synctex=1' -pvc %t" TeX-run-command nil (latex-mode docTeX-mode)))))
    (add-hook 'LaTeX-mode-hook (lambda () (setq TeX-command-default "MkLaTeX")))
    (add-hook 'LaTeX-mode-hook (lambda () (define-key LaTeX-mode-map (kbd "<double-mouse-1>") 'pdf-sync-forward-search)))
    (add-hook 'LaTeX-mode-hook (lambda () (setq LaTeX-math-abbrev-prefix nil))) ;; was `, but now used it for cdlatex math-modify

    ;; advice from online repo
    (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

  (spacemacs|use-package-add-hook tex
    :post-config
    (setq TeX-auto-save t)
    (setq TeX-parse-self t)
    (setq TeX-show-compilation nil)
    ;; (setq-default TeX-master nil)
    ;; (add-hook 'reftex-load-hook '(lambda ()
    ;;                                (define-key reftex-mode-map "k" 'reftex-toc-previous)
    ;;                                (define-key reftex-mode-map "j" 'reftex-toc-next)
    ;;                                ;; k was originally bound to reftex-toc-quit-and-kill, so rebind it
    ;;                                (define-key reftex-mode-map "n" 'reftex-toc-quit-and-kill)
    ;;                                ;; the following keys will be unset
    ;;                                (define-key reftex-mode-map "C-n" nil)
    ;;                                (define-key reftex-mode-map "C-p" nil)
    ;;                                ))
    )
  )

(defun latex-custom/init-cdlatex ()
  (use-package cdlatex
    :load-path "~/Projects/cdlatex"
    :commands turn-on-cdlatex
    :init
    (add-hook 'LaTeX-mode-hook 'turn-on-cdlatex)   ; with AUCTeX LaTeX mode
    (add-hook 'latex-mode-hook 'turn-on-cdlatex)   ; with Emacs latex mode
    :config
    ;; first try expanding yasnippet, then cdlatex-tab
    ;; FIXME when yasnippet is expanded, the tab is bound to yas-next-field-or-maybe-expand
    ;; does this have to do with mode-map order?
    ;; seems that the key bindings for yas-keymap are not run, why?
    ;; (defun smart-tab ()
    ;;   (interactive)
    ;;   (let ((yas-fallback-behavior 'return-nil))
    ;;     (if (null (yas-expand))
    ;;         (cdlatex-tab)
    ;;       )))
    ;; (define-key cdlatex-mode-map "\t" 'smart-tab)

    ;; (defun deco-reftex-label(old_func &optional environment no-insert)
    ;;   "append time string to some labels generated by reftex-label to make it unique in the context of multiple file context"
    ;;   ;; first interrupt the insert, modify it and then insert back
    ;;   (interactive)
    ;;   (let*
    ;;       ((label (funcall old_func environment t))) ;NOTE funcall instead of apply
    ;;     (progn ; NOTE crucial to have progn, otherwise (insert label) will be interpreted as a function. Elisp doesn't evaluate the first cell even if the first cell evaluates to a function
    ;;       (setq label (concat label (format-time-string " %y/%m/%d %H:%M:%S")))
    ;;       (unless no-insert
    ;;         (insert "\\label{" label "}")
    ;;         )
    ;;       )
    ;;     )
    ;;   )
    ;; (advice-add 'reftex-label :around #'deco-reftex-label)

    (custom-set-variables
     '(cdlatex-env-alist
       '(
         ;;------------------------------------
         ( "array"
           "\\begin{array}[tb]{?lcrp{width}*{num}{lcrp{}}|}
     & & & 
\\end{array}"
           "\\\\     ?& & &"
           )

         ))
     )
    ))

;;; packages.el ends here
