(require 'bind-key)

(make-variable-buffer-local
 (defvar region-command-mode-start-position nil
   "The original position of point when region-command-mode was started."))

(make-variable-buffer-local
 (defvar region-command-mode-active nil))

(defvar region-command-mode-keymap (make-sparse-keymap))

(defun region-command-mode-quit ()
  (interactive)
  (if region-command-mode-start-position
      (goto-char region-command-mode-start-position))
  (deactivate-mark))
;; (setq deactivate-mark-hook '())
(bind-keys :map region-command-mode-keymap
           ;; ("c" .  (lambda ()
           ;;           (interactive)
           ;;           (message "c")
           ;;           (deactivate-mark)))
           ("q" . region-command-mode-quit)
           ("<SPC>" . region-command-mode-deactivate)
           ("r" . rectangle-mark-mode)
           ;; ("C-<SPC>" . (lambda ()
           ;;                (interactive)
           ;;                (set-mark-command nil)
           ;;                (set-mark-command (point))))
           ("x" . exchange-point-and-mark))

(define-minor-mode region-command-mode-active-mode
  "Allows commands when the region is active.

This the internal mode that is activated when the region is active. It should
not be used directly. When active, an additional keymap
(`region-command-mode-keymap') is active. Users can add keys to the keymap
`region-command-mode-keymap' to add their own commands. The standard minor mode
hook `region-command-active-mode-hook' can be used."
  :lighter " RCA"
  :keymap region-command-mode-keymap
  (if region-command-mode-active-mode
      (progn
        (setq region-command-mode-start-position (point)))
    (setq region-command-mode-start-position nil)))

(defun region-command-mode-activate ()
  (region-command-mode-active-mode 1))

(defun region-command-mode-deactivate ()
  (interactive)
  (region-command-mode-active-mode 0))

(define-minor-mode region-command-mode
  "Enable region command mode.



"
  :lighter " RC"
  :global t
  (if region-command-mode
      (progn
        (add-hook 'activate-mark-hook 'region-command-mode-activate)
        (add-hook 'deactivate-mark-hook 'region-command-mode-deactivate))
    (add-hook 'activate-mark-hook 'region-command-mode-activate)
    (add-hook 'deactivate-mark-hook 'region-command-mode-deactivate)
    (region-command-mode-deactivate)))
(provide 'region-command-mode)
