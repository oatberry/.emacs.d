;; My Emacs config
;; Author: Thomas Berryhill (oats) <thomas@berryhill.me>

;; straight.el
(setq straight-repository-branch "develop")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

;; enable use-package
(straight-use-package 'use-package)
(use-package use-package-ensure-system-package)

;; don't litter this file >.>
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;; Load config "modules"
(mapc 'load (file-expand-wildcards "~/.emacs.d/lisp/*.el"))

;; font
(set-frame-font "Iosevka SS08-12" nil t)
;; (setq default-frame-alist '((font . "Iosevka SS08-12")))
(set-fontset-font t 'symbol "Noto Color Emoji" nil 'append)
(set-fontset-font t 'symbol "Symbola" nil 'append)

;; kdeconnect
(defun oats/send-to-phone (thing)
  "Send a url/file to my phone"
  (interactive "fFile: ")
  (start-process "kdeconnect" nil
                 "kdeconnect-cli" "--name" "quaestor" "--share" thing)
  (shell-command (string-join `("kdeconnect-cli"
                                "--name" "quaestor"
                                "--share" ,(shell-quote-argument thing))
                              " ")))

(defun oats/send-string-to-phone (text)
  "Send some text to my phone"
  (interactive "sSend: ")
  (shell-command (string-join (list "kdeconnect-cli"
                                    "--name" "quaestor"
                                    "--share-text" (shell-quote-argument text))
                              " ")))

;; Auth
(require 'auth-source-pass)
(auth-source-pass-enable)
(defun oats/pass (path)
  (car (process-lines "pass" path)))

(use-package aggressive-indent
  :hook ((emacs-lisp-mode . aggressive-indent-mode)))

(use-package autopair
  :config (autopair-global-mode))

(use-package company
  :config
  (global-company-mode)
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 1))

(use-package counsel
  :demand
  :bind (("C-s" . swiper)
         ("C-x 8 RET" . counsel-unicode-char)
         ("C-c r" . counsel-rg))
  :config
  ;; (use-package smex)
  (ivy-mode 1)
  (counsel-mode 1)
  (setq ivy-use-virtual-buffers t
        ivy-use-selectable-prompt t
        enable-recursive-minibuffers t
        ivy-count-format "(%d/%d) "))

(use-package ivy-rich
  :after counsel
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-parse-remote-buffer nil))

;; (use-package enwc
;;   :config (setq enwc-default-backend 'nm
;;                 enwc-wired-device "enp0s20u1"
;;                 enwc-wireless-device "wlp2s0")
;;   :hook (enwc-mode . (lambda () (evil-emacs-state))))

(use-package undo-tree
  :config
  (setq undo-tree-auto-save-history t
        undo-tree-history-directory-alist '(("." . "/home/oats/.emacs.d/undo")))
  (global-undo-tree-mode))

(use-package evil
  :after undo-tree
  :custom
  (evil-undo-system 'undo-tree)
  (evil-magic 'very-magic)
  (evil-respect-visual-line-mode t)
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (evil-select-search-module 'evil-search-module 'evil-search))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode))

(use-package evil-surround
  :config (global-evil-surround-mode 1))

(use-package expand-region
  :after evil
  :bind (:map evil-normal-state-map
              ("SPC" . 'er/expand-region)))

;; (use-package flycheck
;;   :config (global-flycheck-mode))

;; (use-package gruvbox-theme
;;   :config (load-theme 'gruvbox-dark-hard))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme (pcase (system-name)
                ("senator" 'doom-one-light)
                ("praetor" 'doom-one))
              t))

(use-package ibuffer-vc
  :bind ("C-x C-b" . ibuffer)
  :hook (ibuffer-mode-hook . (lambda () (ibuffer-switch-to-saved-filter-groups
                                         "home")))
  :config (setq ibuffer-saved-filter-groups
                '(("home"
                   ("Org" (mode . org-mode))
                   ("code" (or (filename . "projects")
                               (filename . "school")))
                   ("school" (filename . "school"))
                   ("erc" (mode . erc-mode))))))

(use-package plz
  :straight (plz :type git :host github :repo "alphapapa/plz.el"))
(use-package ement
  :after plz
  :straight (ement :type git :host github :repo "alphapapa/ement.el"))

(use-package vterm
  :config
  (setq vterm-max-scrollback 20000)
  (evil-define-key 'normal vterm-mode-map "p" 'vterm-yank)
  (evil-define-key 'normal vterm-mode-map "P" 'vterm-yank)
  (evil-define-key 'insert vterm-mode-map (kbd "C-y") 'vterm-yank)
  :bind (:map vterm-mode-map
              ("<prior>" . scroll-down-command)
              ("<next>" . scroll-up-command)
              ("C-s" . swiper))
  :hook (vterm-mode . (lambda ()
                        (company-mode 0)
                        (display-line-numbers-mode 0)
                        (setq-local global-hl-line-mode nil))))

(use-package which-key
  :config (which-key-mode 1))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package latex-preview-pane)

(use-package link-hint
  :config
  (link-hint-define-type 'text-url
    :send-to-phone 'oats/send-to-phone)

  (defun link-hint-send-link-to-phone ()
    "Use avy to select a link and send it to my phone"
    (interactive)
    (avy-with link-hint-send-link-to-phone
      (link-hint--one :send-to-phone)))

  :bind (("C-c l o" . link-hint-open-link)
         ("C-c l c" . link-hint-copy-link)
         ("C-c l s" . link-hint-send-link-to-phone)))

;; (use-package lilypond
;;   :repo )

(use-package lispyville
  :hook ((emacs-lisp-mode . lispyville-mode)
		 (lisp-mode . lispyville-mode))
  :config
  (lispyville-set-key-theme
   '(operators c-w slurp/barf-lispy additional-wrap additional-motions additional text-objects)))

(use-package lsp-mode
  :hook ((go-mode . lsp))
  :init (setq lsp-keymap-prefix "C-M-l")
  :commands lsp)

(use-package all-the-icons)
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; (use-package moody
;;   :config
;;   (setq x-underline-at-descent-line t
;;         moody-mode-line-height 25)
;;   (moody-replace-mode-line-buffer-identification)
;;   (moody-replace-vc-mode))

(use-package yasnippet
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

(use-package yasnippet-snippets)

;; c-mode
(with-eval-after-load "cc-mode"
  (add-hook 'c-mode-hook
            (lambda ()
              (define-key c-mode-base-map (kbd "C-c C-c") 'compile)
              (define-key c-mode-base-map (kbd "C-c C-r") 'recompile)
              (define-key c-mode-base-map (kbd "C-c C-g") 'gdb)
              (c-toggle-comment-style -1)
              (c-set-offset 'case-label '+)
              (setq compilation-always-kill t
	                compilation-scroll-output t))))

;; clojure
(use-package clojure-mode)
(use-package cider)

;; golang
(use-package go-mode
  :init (add-hook 'go-mode-hook
                  (lambda ()
                    (add-hook 'before-save-hook #'lsp-format-buffer t t)
                    (add-hook 'before-save-hook #'lsp-organize-imports t t)
                    (go-eldoc-setup)
                    (setq compile-command "go build -v")
                    (setq compilation-read-command nil)))
  :bind (:map go-mode-map
              ("C-c C-c" . compile)))

;; haskell
(use-package haskell-mode
  :hook ((haskell-mode . lsp)
         (haskell-mode . (lambda ()
                           (setq tab-width 2)
                           (interactive-haskell-mode))))
  :config
  (setq haskell-process-auto-import-loaded-modules t
        haskell-interactive-popup-errors nil))

(use-package lsp-haskell
  :after lsp
  :hook (before-save-hook . lsp-format-buffer)
  :init
  (lsp-haskell-set-hlint t)
  (lsp-haskell-set-formatter :brittany))

;; lua
(use-package lua-mode
  :config
  (setq lua-indent-level 4)

  (defun lua-send-file (file-name)
    "Load a Lua file FILE-NAME into the Lua process."
    (interactive (comint-get-source "Load lua file: " lua-prev-l/c-dir/file
                                    '(lua-mode) t))
    (comint-check-source file-name)
    (setq lua-prev-l/c-dir/file (cons (file-name-directory    file-name)
                                      (file-name-nondirectory file-name)))
    (let ((command (format "print(''); f, err = loadfile(%s, 't'); if err then print(err) else f() end"
                           (lua-make-lua-string file-name))))
      (lua-send-string command)
      (when lua-always-show (lua-show-process-buffer))))

  :bind (:map lua-mode-map
              ("C-c C-l" . lua-send-file)))

(defvar lua-prev-l/c-dir/file nil) ; idk

;; fennel
(use-package fennel-mode
  :hook (fennel-mode . aggressive-indent-mode))

;; racket
(use-package racket-mode
  :hook ((racket-mode . racket-xp-mode)
         (racket-mode . lispyville-mode)
         (racket-mode . aggressive-indent-mode)
         (racket-mode . (lambda () (setq-local font-lock-maximum-decoration 3)))
         (racket-repl-mode . lispyville-mode)
         (racket-xp-mode . (lambda () (remove-hook 'pre-redisplay-functions
                                                   #'racket-xp-pre-redisplay
                                                   t)))))

;; rust
(use-package rust-mode
  :config (setq indent-tabs-mode nil
                rust-format-on-save t)
  :bind (:map rust-mode-map
              ("C-c C-c" . rust-compile)
              ("C-c C-r" . rust-run)
              ("C-c C-t" . rust-test)))

;; zig
(use-package zig-mode
  :after lsp-mode
  :hook (zig-mode . lsp)
  :config
  (setq zig-format-on-save nil)
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection (executable-find "zls"))
    :major-modes '(zig-mode)
    :server-id 'zls)))

;; org-mode
(use-package org
  ;; :straight (:type built-in)
  :config
  (setq org-agenda-files '("inbox.org")
        org-blank-before-new-entry '((heading . nil)
                                     (plain-list-item . nil))
        org-capture-templates `(("i" "Inbox" entry  (file "inbox.org")
                                 ,(concat "* TODO %?\n"
                                          "/Entered on/ %U")))
        org-cycle-separator-lines 1
	    org-ellipsis "⤵"
        org-file-apps '((auto-mode . emacs)
                        ("\\.mm\\'" . default)
                        ("\\.x?html?\\'" . "plumb %s")
                        ("\\.pdf\\'" . default))
        org-format-latex-options '(:foreground default :background default :scale 1.75 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\["))
	    org-hide-emphasis-markers t
	    org-hide-leading-stars t
	    org-src-fontify-natively t
	    org-src-tab-acts-natively t
	    org-src-window-setup 'current-window
	    org-startup-indented t
	    org-startup-folded nil
	    org-startup-with-inline-images t)

  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)))

;; term and eshell
(add-hook 'term-mode-hook (lambda () (display-line-numbers-mode 0)))
(add-hook 'eshell-mode-hook (lambda ()
                              (display-line-numbers-mode 0)
                              (setq-local global-hl-line-mode nil)))
(add-hook 'inferior-lisp-mode-hook 'lispyville-mode)

;; look 'n feel
(blink-cursor-mode -1)
(global-auto-revert-mode t)
(global-hl-line-mode)
(global-display-line-numbers-mode 1)
(set-face-background 'line-number nil)
(show-paren-mode 1)
(transient-mark-mode t)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'prog-mode-hook 'subword-mode)
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
(add-hook 'before-save-hook
          (lambda ()
            (when buffer-file-name
              (let ((dir (file-name-directory buffer-file-name)))
                (when (and (not (file-exists-p dir))
                           (y-or-n-p (format "Directory %s does not exist. Create it?" dir)))
                  (make-directory dir t))))))

(fset 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd "M-o") 'other-window)
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(setq backup-by-copying t     ; don't clobber symlinks
      backup-directory-alist
      '(("." . "~/.emacs.d/backup/"))  ; don't litter my fs tree
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)      ; use versioned backups

(add-hook 'dired-mode-hook 'auto-revert-mode)

;; only run gc when minibuffer is not focused
(add-hook 'minibuffer-setup-hook
          (lambda () (setq gc-cons-threshold most-positive-fixnum)))
(add-hook 'minibuffer-exit-hook
          (lambda () (setq gc-cons-threshold 800000)))

(setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "plumb")
(setq gc-cons-threshold 800000)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")
(setq mouse-wheel-follow-mouse t)
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq reb-re-syntax 'string)
(setq scroll-conservatively 150)
(setq scroll-margin 1)
(setq scroll-step 1)
(setq sentence-end-double-space nil)
(setq show-paren-delay 0)
(setq tramp-default-method "ssh")
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)
(setq visible-bell nil)
(setq-default c-basic-offset 4)
(setq-default dired-listing-switches "-alh")
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
