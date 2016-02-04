(require 'bind-key)

(make-variable-buffer-local
 (defvar region-command-mode-start-position nil
   "The original position of point when region-command-mode was started."))

(make-variable-buffer-local
 (defvar region-command-mode-depth 0))

(defvar region-command-mode-keymap (make-sparse-keymap))

(defun region-command-mode-quit ()
  (interactive)
  (if region-command-mode-start-position
      (goto-char region-command-mode-start-position))
  (deactivate-mark))
;; (setq deactivate-mark-hook '())
(bind-keys :map region-command-mode-keymap
           ("q" . region-command-mode-quit)
           ("<SPC>" . region-command-mode-deactivate)
           ("r" . rectangle-mark-mode)
           ("x" . exchange-point-and-mark))

(define-minor-mode region-command-active-mode
  "Allows commands when the region is active.

This the internal mode that is activated when the region is active. It should
not be used directly. When active, an additional keymap
(`region-command-mode-keymap') is active. Users can add keys to the keymap
`region-command-mode-keymap' to add their own commands. The standard minor mode
hook `region-command-active-mode-hook' can be used."
  :lighter " RCA"
  :keymap region-command-mode-keymap
  (if region-command-active-mode
      (progn
        (add-hook 'post-command-hook 'region-command-mode--check-if-done)
        (setq region-command-mode-start-position (point)))
    (remove-hook 'post-command-hook 'region-command-mode--check-if-done)
    (setq region-command-mode-start-position nil)))

(defun region-command-mode--check-if-done ()
  ;; (message "checking if done %s %s" mark-active deactivate-mark)
  (when (or (not mark-active) deactivate-mark)
    (region-command-mode-deactivate)))

(defun region-command-mode-activate ()
  (unless region-command-active-mode
    ;; (message "region-command-mode-activating")
    (region-command-active-mode 1)))

(defun region-command-mode-deactivate ()
  (interactive)
  ;; (message "region-command-mode-deactivating")
  (region-command-active-mode 0))

;;;###autoload
(define-minor-mode region-command-mode
  "Enable region command mode.
"
  :lighter " RC"
  :global t
  (if region-command-mode
      (progn
        (add-hook 'activate-mark-hook 'region-command-mode-activate)
        ;; (add-hook 'deactivate-mark-hook 'region-command-mode-deactivate)
        )
    (remove-hook 'activate-mark-hook 'region-command-mode-activate)
    ;; (remove-hook 'deactivate-mark-hook 'region-command-mode-deactivate)
    (region-command-mode-deactivate)))


(provide 'region-command-mode)
