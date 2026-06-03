;;; init.el --- Pretty Emacs for notes, TODOs and linked knowledge base

;;; ------------------------------------------------------------
;;; Package setup
;;; ------------------------------------------------------------

(require 'package)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)

;;; ------------------------------------------------------------
;;; Basic UI
;;; ------------------------------------------------------------

(setq inhibit-startup-message t)
(setq initial-scratch-message "")

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(visual-line-mode 1)
(set-frame-parameter nil 'fullscreen 'fullboth)

(set-fringe-mode 10)

(setq ring-bell-function 'ignore)
(setq visible-bell nil)

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq scroll-conservatively 101)

(fset 'yes-or-no-p 'y-or-n-p)

(load-theme 'wombat t)

;;; ------------------------------------------------------------
;;; Fonts / visual comfort
;;; ------------------------------------------------------------

(set-face-attribute 'default nil
                    :height 140)

(set-face-attribute 'fixed-pitch nil
                    :height 140)

(set-face-attribute 'variable-pitch nil
                    :height 150
                    :weight 'regular)


;;; ------------------------------------------------------------
;;; Line numbers
;;; ------------------------------------------------------------

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

(add-hook 'org-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)))


;;; ------------------------------------------------------------
;;; Better completion
;;; ------------------------------------------------------------

(use-package vertico
  :init
  (vertico-mode 1))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package consult)

;;; ------------------------------------------------------------
;;; Evil mode
;;; ------------------------------------------------------------
(setq-default cursor-type 'box)
(blink-cursor-mode -1)

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (evil-set-leader 'normal (kbd "SPC"))
  ;; Always use solid block cursor
  (setq-default cursor-type 'box)
  (setq evil-normal-state-cursor 'box)
  (setq evil-insert-state-cursor 'box)
  (setq evil-visual-state-cursor 'box)
  (setq evil-replace-state-cursor 'box)
  (setq evil-motion-state-cursor 'box)
  (setq evil-emacs-state-cursor 'box))

;;; ------------------------------------------------------------
;;; Notes directory
;;; ------------------------------------------------------------

(defvar my/notes-directory (expand-file-name "~/notes/"))

(unless (file-directory-p my/notes-directory)
  (make-directory my/notes-directory t))

;;; ------------------------------------------------------------
;;; Org mode
;;; ------------------------------------------------------------

(use-package org
  :ensure nil
  :config

  (setq org-directory my/notes-directory)

  ;; Agenda sees all .org files inside ~/notes
  (setq org-agenda-files
	(seq-remove
	 (lambda (file)
	   (string-match-p "/\\.?#\\|/\\.#" file))
	 (directory-files-recursively org-directory "\\.org$")))
  
  ;; Pretty Org behavior
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-ellipsis " ▾")
  (setq org-hide-emphasis-markers t)

  ;; Images
  (setq org-startup-with-inline-images t)
  (setq org-image-actual-width 500)

  ;; TODO states
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))

  ;; Nice bullets / headings
  (setq org-log-done 'time)

  ;; Capture templates
  (setq org-default-notes-file
        (expand-file-name "inbox.org" org-directory))

  (setq org-capture-templates
	'(("t" "Todo to inbox" entry
	   (file "inbox.org")
	   "* TODO [#C] %? :inbox:\n  Created: %U\n")

	  ("T" "Todo in current note" entry
	   (function my/org-capture-current-note-tasks)
	   "** TODO [#C] %?\n   Created: %U\n   Context: %a\n")

	  ("n" "Note to inbox" entry
	   (file "inbox.org")
	   "* %?\n  Created: %U\n")

	  ("j" "Journal" entry
	   (file+datetree "journal.org")
	   "* %?\n  Created: %U\n")))

  ;; Refile between notes
  (setq org-refile-targets
        '((org-agenda-files :maxlevel . 3)))

  ;; Faces
  (custom-set-faces
   '(org-document-title ((t (:height 1.5 :weight bold))))
   '(org-level-1 ((t (:height 1.35 :weight bold))))
   '(org-level-2 ((t (:height 1.20 :weight bold))))
   '(org-level-3 ((t (:height 1.10 :weight bold))))
   '(org-level-4 ((t (:height 1.05 :weight bold))))))

;; Priorities from A to E
(setq org-highest-priority ?A)
(setq org-lowest-priority ?E)
(setq org-default-priority ?C)

(setq org-agenda-prefix-format
      '((agenda . " %i %?-12t")
        (todo   . " %i ")
        (tags   . " %i ")
        (search . " %i ")))

(setq org-agenda-remove-tags t)
(setq org-agenda-tags-column 0)

;;; ------------------------------------------------------------
;;; Pretty Org UI
;;; ------------------------------------------------------------

(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿"))
  (setq org-modern-hide-stars nil)
  (setq org-modern-table t)
  (setq org-modern-list
	'((?+ . "•")
	  (?- . "–")
	  (?* . "◦")))

  (setq org-modern-priority-faces
	'((?A :background "#E06666" :foreground "black" :weight bold)
	  (?B :background "#F0A66B" :foreground "black" :weight bold)
	  (?C :background "#F7E26B" :foreground "black" :weight bold)
	  (?D :background "#8BC34A" :foreground "black" :weight bold)
	  (?E :background "#5DADE2" :foreground "black" :weight bold))))

;;; ------------------------------------------------------------
;;; Variable pitch in Org
;;; ------------------------------------------------------------

(use-package mixed-pitch
  :hook
  (org-mode . mixed-pitch-mode))


;;; ------------------------------------------------------------
;;; Org Roam: linked notes like Obsidian
;;; ------------------------------------------------------------

(use-package org-roam
  :custom
  (org-roam-directory my/notes-directory)
  (org-roam-completion-everywhere t)
  :config
  (org-roam-db-autosync-mode 1)

  (setq org-roam-capture-templates
	'(("d" "default" plain
	   "%?"
	   :target
	   (file+head
	    "%<%Y%m%d%H%M%S>-${slug}.org"
	    "#+title: ${title}\n#+created: %U\n\n* Notes\n\n* Tasks\n")
	   :unnarrowed t)

	  ("p" "project" plain
	   "* Goal\n%?\n\n* Notes\n\n* Tasks\n\n* Decisions\n\n* Links\n"
	   :target
	   (file+head
	    "projects/${slug}.org"
	    "#+title: ${title}\n#+created: %U\n#+filetags: :project:\n\n")
	   :unnarrowed t))))

;;; ------------------------------------------------------------
;;; Org Roam UI: graph view like Obsidian
;;; ------------------------------------------------------------

(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t)
  (setq org-roam-ui-follow t)
  (setq org-roam-ui-update-on-save t)
  (setq org-roam-ui-open-on-start nil))


;;; ------------------------------------------------------------
;;; Helper functions
;;; ------------------------------------------------------------

(defun my/open-notes-directory ()
  "Open notes directory."
  (interactive)
  (dired my/notes-directory))

(defun my/open-inbox ()
  "Open inbox.org."
  (interactive)
  (find-file (expand-file-name "inbox.org" my/notes-directory)))

(defun my/open-emacs-config ()
  "Open Emacs config."
  (interactive)
  (find-file user-init-file))

(defun my/org-capture-current-note-tasks ()
  "Capture task into Tasks heading of current Org note."
  (interactive)
  (let ((file (buffer-file-name)))
    (unless file
      (user-error "Current buffer is not visiting a file"))
    (set-buffer (org-capture-target-buffer file))
    (goto-char (point-min))
    (unless (re-search-forward "^\\* Tasks" nil t)
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert "\n* Tasks\n"))
    (goto-char (point-min))
    (re-search-forward "^\\* Tasks")
    (org-end-of-subtree)))

;;; ------------------------------------------------------------
;;; Dired + Evil
;;; ------------------------------------------------------------

(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh")

  (with-eval-after-load 'evil
    (evil-set-initial-state 'dired-mode 'normal)

    (evil-define-key 'normal dired-mode-map
      (kbd "j") #'dired-next-line
      (kbd "k") #'dired-previous-line
      (kbd "h") #'dired-up-directory
      (kbd "l") #'dired-find-file
      (kbd "RET") #'dired-find-file
      (kbd "-") #'dired-up-directory
      (kbd "q") #'quit-window
      (kbd "r") #'revert-buffer
      (kbd "m") #'dired-mark
      (kbd "u") #'dired-unmark
      (kbd "x") #'dired-do-flagged-delete
      (kbd "D") #'dired-do-delete
      (kbd "C") #'dired-do-copy
      (kbd "R") #'dired-do-rename
      (kbd "+") #'dired-create-directory)))

;;; ------------------------------------------------------------
;;; Keybindings
;;; ------------------------------------------------------------

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c n") #'org-roam-node-find)
(global-set-key (kbd "C-c i") #'org-roam-node-insert)
(global-set-key (kbd "C-c b") #'org-roam-buffer-toggle)
(global-set-key (kbd "C-c e") #'my/open-emacs-config)

(with-eval-after-load 'evil
  (evil-define-key 'normal 'global
    (kbd "<leader>b") #'consult-buffer

    ;; Quality Of Life
    (kbd "<leader>w") evil-window-map
    (kbd "<leader>h") help-map
    (kbd "-") #'dired-jump

    ;; Files / notes
    (kbd "<leader>n n") #'org-roam-node-find
    (kbd "<leader>n i") #'org-roam-node-insert
    (kbd "<leader>n b") #'org-roam-buffer-toggle
    (kbd "<leader>n g") #'org-roam-ui-open
    (kbd "<leader>n o") #'my/open-notes-directory
    (kbd "<leader>n x") #'my/open-inbox

    ;; Org
    (kbd "<leader>o a") #'org-agenda
    (kbd "<leader>o c") #'org-capture
    (kbd "<leader>o t") #'org-todo-list

    ;; Config
    (kbd "<leader>e") #'my/open-emacs-config
    (kbd "<leader>l") #'magit-status ;; l because i'm used to lazygit
    ))

(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map
    (kbd "TAB") #'org-cycle
    (kbd "<tab>") #'org-cycle
    (kbd "S-TAB") #'org-global-cycle
    (kbd "<backtab>") #'org-global-cycle))


;;; ------------------------------------------------------------
;;; Create starter files
;;; ------------------------------------------------------------

(let ((inbox-file (expand-file-name "inbox.org" my/notes-directory))
      (tasks-file (expand-file-name "tasks.org" my/notes-directory))
      (home-file  (expand-file-name "home.org" my/notes-directory)))

  (unless (file-exists-p inbox-file)
    (with-temp-file inbox-file
      (insert "#+title: Inbox\n\n* Notes\n\n* Tasks\n")))

  (unless (file-exists-p tasks-file)
    (with-temp-file tasks-file
      (insert "#+title: Tasks\n\n* TODO Example task\n  SCHEDULED: <2026-06-02 Tue>\n")))

  (unless (file-exists-p home-file)
    (with-temp-file home-file
      (insert "#+title: Home\n\nWelcome to your notes.\n\nUse `C-c n` to create or find notes.\n"))))

;;; ------------------------------------------------------------
;; Open links everywhere!
;;; ------------------------------------------------------------
(setq browse-url-browser-function #'browse-url-generic
      browse-url-generic-program "wslview")

;;; ------------------------------------------------------------
;;; Final
;;; ------------------------------------------------------------

(provide 'init)

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   '("/home/phtea/notes/projects/notes.org" "/home/phtea/notes/projects/phonk_song_idea.org" "/home/phtea/notes/20260603011815-fl_studio_tutorials.org" "/home/phtea/notes/20260603015114-fl_studio.org" "/home/phtea/notes/20260603142529-emacs.org" "/home/phtea/notes/20260603142734-magit.org" "/home/phtea/notes/home.org" "/home/phtea/notes/inbox.org" "/home/phtea/notes/journal.org" "/home/phtea/notes/tasks.org"))
 '(package-selected-packages
   '(org-roam-ui org-roam mixed-pitch org-appear vertico org-modern orderless marginalia magit gnu-elpa-keyring-update evil consult)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-title ((t (:height 1.5 :weight bold))))
 '(org-level-1 ((t (:height 1.35 :weight bold))))
 '(org-level-2 ((t (:height 1.2 :weight bold))))
 '(org-level-3 ((t (:height 1.1 :weight bold))))
 '(org-level-4 ((t (:height 1.05 :weight bold)))))
