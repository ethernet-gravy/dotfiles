(setq doom-localleader-key ",")

(setq doom-theme 'modus-vivendi)

(setq display-line-numbers-type `relative)

(after! evil
  (setq evil-shift-round nil)
  (setq evil-respect-visual-line-mode t))

(setq which-key-idle-delay 0.5)

(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))
   ))

(add-hook 'org-mode-hook 'turn-on-org-cdlatex)
(add-hook 'LaTeX-mode-hook 'turn-on-cdlatex)

(defun enable-word-processor-minor-modes ()
  (setq line-spacing 0.15)
  ;;(pixel-scroll-precision-mode)
  (smartparens-mode)
  (visual-line-mode))
;;  (add-hook 'window-size-change-functions 'org-image-resize)
(add-hook 'text-mode-hook 'enable-word-processor-minor-modes)
;;(add-hook 'org-mode-hook 'org-appear-mode)
(add-hook 'org-mode-hook 'org-roam-db-autosync-enable)
(add-hook 'org-mode-hook 'org-latex-preview-mode)
(after! org
  (setq org-directory "~/notes/org-mode/")
  (setq org-roam-directory "~/notes/org-mode/")
  (setq org-habit-show-habits-only-for-today nil)
  (setq org-agenda-files (directory-files-recursively "~/notes/org-mode/" "\\.org$"))
  (setq org-pretty-entities t)
  (setq org-hide-emphasis-markers t)
  (setq org-startup-folded 'content)
  ;; (setq org-startup-with-inline-images t)
  (setq org-startup-with-link-previews t)
  (setq org-ellipsis " ")) ;; folding symbol

(setq doom-font (font-spec :family "Iosevka Nerd Font Mono" :size 18)
      doom-variable-pitch-font (font-spec :family "Vollkorn"))

(after! writeroom-mode
  (setq +zen-text-scale 0)
  (setq writeroom-width 250)
  )
(add-hook 'org-mode-hook '+zen/toggle)

(after! org
  (add-hook 'org-mode-hook #'doom-disable-line-numbers-h))

(after! evil
  (map! :nv "j" #'evil-next-visual-line
        :nv "k" #'evil-previous-visual-line))

(setq-default major-mode 'org-mode)

(after! org
  (setq org-appear-autolinks t)
  (setq org-appear-autoentities t)
  (setq org-appear-autosubmarkers t)
  (setq org-appear-autokeywords t)
  (setq org-appear-inside-latex t)
  )

;; It's cool to have appear only work in insert mode, gonna leave in automatic for now
;; (setq org-appear-trigger 'manual)
;; (add-hook 'org-mode-hook (lambda ()
;;                           (add-hook 'evil-insert-state-entry-hook
;;                                     #'org-appear-manual-start
;;                                     nil
;;                                     t)
;;                           (add-hook 'evil-insert-state-exit-hook
;;                                     #'org-appear-manual-stop
;;                                     nil
;;                                     t)))

(after! org-download
  (setq org-download-method 'directory)
  (setq org-download-image-dir (concat org-directory ".attach/" ))
  (setq org-download-link-format "[[file:%s]]\n"
        org-download-abbreviate-filename-function #'file-relative-name)
  (setq org-download-link-format-function #'org-download-link-format-function-default)
  (setq org-download-disable-id-create t)
)

(after! org
(advice-remove 'org-download-clipboard 'org-id-get-create))

(defun patch/emacsql-close (connection &rest args)
  "Prevent calling emacsql-close if connection handle is nil."
  (when (oref connection handle)
    t))

(advice-add 'emacsql-close :before-while #'patch/emacsql-close)

(after! org
  (setq org-roam-db-location "~/notes/org-mode/org.db"))

(after! org
  (setq org-indent-indentation-per-level 4))

(after! org
  (setq org-fold-core-style 'overlays)
  (evil-select-search-module 'evil-search-module 'evil-search))

(set-frame-parameter nil 'alpha-background 0.6)

(set-eglot-client! 'cc-mode '("clangd" "-j=3" "--clang-tidy"))

(setq projectile-cache-file (concat doom-cache-dir "projectile.cache")
        projectile-enable-caching (not noninteractive)
        projectile-indexing-method (if IS-WINDOWS 'native 'alien)
        projectile-known-projects-file (concat doom-cache-dir "projectile.projects")
        projectile-require-project-root nil
        projectile-globally-ignored-files '(".DS_Store" "Icon
" "TAGS")
        projectile-globally-ignored-file-suffixes '(".elc" ".pyc" ".o")
        projectile-ignored-projects '("~/" "/tmp"))
